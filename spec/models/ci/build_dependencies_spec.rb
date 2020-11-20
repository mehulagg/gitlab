# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::BuildDependencies do
  let_it_be(:user) { create(:user) }
  let_it_be(:project, reload: true) { create(:project, :repository) }

  let_it_be(:pipeline, reload: true) do
    create(:ci_pipeline, project: project,
                         sha: project.commit.id,
                         ref: project.default_branch,
                         status: 'success')
  end

  let!(:build) { create(:ci_build, pipeline: pipeline, name: 'build', stage_idx: 0, stage: 'build') }
  let!(:rspec_test) { create(:ci_build, pipeline: pipeline, name: 'rspec', stage_idx: 1, stage: 'test') }
  let!(:rubocop_test) { create(:ci_build, pipeline: pipeline, name: 'rubocop', stage_idx: 1, stage: 'test') }
  let!(:staging) { create(:ci_build, pipeline: pipeline, name: 'staging', stage_idx: 2, stage: 'deploy') }

  describe '#local' do
    subject { described_class.new(job).local }

    describe 'jobs from previous stages' do
      context 'when job is in the first stage' do
        let(:job) { build }

        it { is_expected.to be_empty }
      end

      context 'when job is in the second stage' do
        let(:job) { rspec_test }

        it 'contains all jobs from the first stage' do
          is_expected.to contain_exactly(build)
        end
      end

      context 'when job is in the last stage' do
        let(:job) { staging }

        it 'contains all jobs from all previous stages' do
          is_expected.to contain_exactly(build, rspec_test, rubocop_test)
        end

        context 'when a job is retried' do
          before do
            project.add_developer(user)
          end

          let(:retried_job) { Ci::Build.retry(rspec_test, user) }

          it 'contains the retried job instead of the original one' do
            is_expected.to contain_exactly(build, retried_job, rubocop_test)
          end
        end
      end
    end

    describe 'jobs from specified dependencies' do
      let(:dependencies) { }
      let(:needs) { }

      let!(:job) do
        scheduling_type = needs.present? ? :dag : :stage

        create(:ci_build,
          pipeline: pipeline,
          name: 'final',
          scheduling_type: scheduling_type,
          stage_idx: 3,
          stage: 'deploy',
          options: { dependencies: dependencies }
        )
      end

      before do
        needs.to_a.each do |need|
          create(:ci_build_need, build: job, **need)
        end
      end

      context 'when dependencies are defined' do
        let(:dependencies) { %w(rspec staging) }

        it { is_expected.to contain_exactly(rspec_test, staging) }
      end

      context 'when needs are defined' do
        let(:needs) do
          [
            { name: 'build',   artifacts: true },
            { name: 'rspec',   artifacts: true },
            { name: 'staging', artifacts: true }
          ]
        end

        it { is_expected.to contain_exactly(build, rspec_test, staging) }
      end

      context 'when need artifacts are defined' do
        let(:needs) do
          [
            { name: 'build',   artifacts: true },
            { name: 'rspec',   artifacts: false },
            { name: 'staging', artifacts: true }
          ]
        end

        it { is_expected.to contain_exactly(build, staging) }
      end

      context 'when needs and dependencies are defined' do
        let(:dependencies) { %w(rspec staging) }
        let(:needs) do
          [
            { name: 'build',   artifacts: true },
            { name: 'rspec',   artifacts: true },
            { name: 'staging', artifacts: true }
          ]
        end

        it { is_expected.to contain_exactly(rspec_test, staging) }
      end

      context 'when needs and dependencies contradict' do
        let(:dependencies) { %w(rspec staging) }
        let(:needs) do
          [
            { name: 'build',   artifacts: true },
            { name: 'rspec',   artifacts: false },
            { name: 'staging', artifacts: true }
          ]
        end

        it 'returns only the intersection' do
          is_expected.to contain_exactly(staging)
        end
      end

      context 'when nor dependencies or needs are defined' do
        it 'returns the jobs from previous stages' do
          is_expected.to contain_exactly(build, rspec_test, rubocop_test, staging)
        end
      end
    end
  end

  describe '#cross_pipeline' do
    let!(:job) do
      create(:ci_build,
        pipeline: pipeline,
        name: 'build_with_pipeline_dependency',
        options: { cross_dependencies: dependencies })
    end

    subject { described_class.new(job) }

    let(:cross_pipeline_deps) { subject.cross_pipeline }

    context 'when dependency specifications are valid' do
      context 'when pipeline exists in the hierarchy' do
        let!(:pipeline) { create(:ci_pipeline, child_of: parent_pipeline) }
        let!(:parent_pipeline) { create(:ci_pipeline, project: project) }

        context 'when job exists' do
          let(:dependencies) do
            [{ pipeline: parent_pipeline.id.to_s, job: upstream_job.name, artifacts: true }]
          end

          let!(:upstream_job) { create(:ci_build, :success, pipeline: parent_pipeline) }

          it { expect(cross_pipeline_deps).to contain_exactly(upstream_job) }
          it { is_expected.to be_valid }

          context 'when pipeline and job are specified via variables' do
            let(:dependencies) do
              [{ pipeline: '$parent_pipeline_ID', job: '$UPSTREAM_JOB', artifacts: true }]
            end

            before do
              job.yaml_variables.push(key: 'parent_pipeline_ID', value: parent_pipeline.id.to_s, public: true)
              job.yaml_variables.push(key: 'UPSTREAM_JOB', value: upstream_job.name, public: true)
              job.save!
            end

            it { expect(cross_pipeline_deps).to contain_exactly(upstream_job) }
            it { is_expected.to be_valid }
          end

          context 'when feature flag `ci_cross_pipeline_artifacts_download` is disabled' do
            before do
              stub_feature_flags(ci_cross_pipeline_artifacts_download: false)
            end

            it { expect(cross_pipeline_deps).to be_empty }
            it { is_expected.to be_valid }
          end
        end

        context 'when jobs exist but too many cross pipeline dependencies are specified' do
          let(:cross_pipeline_limit) do
            ::Gitlab::Ci::Config::Entry::Needs::NEEDS_CROSS_PIPELINE_DEPENDENCIES_LIMIT
          end

          before do
            cross_pipeline_limit.next.times do |index|
              create(:ci_build, :success,
                pipeline: parent_pipeline, name: "dependency-#{index}",
                stage_idx: 1, stage: 'build', user: user
              )
            end
          end

          let(:dependencies) do
            Array.new(cross_pipeline_limit.next) do |index|
              {
                pipeline: parent_pipeline.id.to_s,
                job: "dependency-#{index}",
                artifacts: true
              }
            end
          end

          it 'returns a limited number of dependencies' do
            expect(cross_pipeline_deps.size).to eq(cross_pipeline_limit)
          end
        end

        context 'when job does not exist' do
          let(:dependencies) do
            [{ pipeline: parent_pipeline.id.to_s, job: 'non-existent', artifacts: true }]
          end

          it { expect(cross_pipeline_deps).to be_empty }
          it { is_expected.not_to be_valid }
        end
      end

      context 'when pipeline does not exist' do
        let(:dependencies) do
          [{ pipeline: '123', job: 'non-existent', artifacts: true }]
        end

        it { expect(cross_pipeline_deps).to be_empty }
        it { is_expected.not_to be_valid }
      end

      context 'when jobs exist in different pipelines in the hierarchy' do
        let!(:pipeline) { create(:ci_pipeline, child_of: parent_pipeline) }
        let!(:parent_pipeline) { create(:ci_pipeline, project: project) }
        let!(:parent_job) { create(:ci_build, :success, name: 'parent_job', pipeline: parent_pipeline) }

        let!(:sibling_pipeline) { create(:ci_pipeline, child_of: parent_pipeline) }
        let!(:sibling_job) { create(:ci_build, :success, name: 'sibling_job', pipeline: sibling_pipeline) }

        context 'when pipeline and jobs dependencies are mismatched' do
          let(:dependencies) do
            [
              { pipeline: parent_pipeline.id.to_s, job: sibling_job.name, artifacts: true },
              { pipeline: sibling_pipeline.id.to_s, job: parent_job.name, artifacts: true }
            ]
          end

          it { expect(cross_pipeline_deps).to be_empty }
          it { is_expected.not_to be_valid }

          context 'when dependencies contain a valid pair' do
            let(:dependencies) do
              [
                { pipeline: parent_pipeline.id.to_s, job: sibling_job.name, artifacts: true },
                { pipeline: sibling_pipeline.id.to_s, job: parent_job.name, artifacts: true },
                { pipeline: sibling_pipeline.id.to_s, job: sibling_job.name, artifacts: true }
              ]
            end

            it 'filters out the invalid ones' do
              expect(cross_pipeline_deps).to contain_exactly(sibling_job)
            end

            it { is_expected.not_to be_valid }
          end
        end
      end

      context 'when job and pipeline exist outside the hierarchy' do
        let!(:pipeline) { create(:ci_pipeline, project: project) }
        let!(:another_pipeline) { create(:ci_pipeline, project: project) }
        let!(:dependency) { create(:ci_build, :success, pipeline: another_pipeline) }

        let(:dependencies) do
          [{ pipeline: another_pipeline.id.to_s, job: dependency.name, artifacts: true }]
        end

        it 'ignores jobs outside the pipeline hierarchy' do
          expect(cross_pipeline_deps).to be_empty
        end

        it { is_expected.not_to be_valid }
      end

      context 'when current pipeline is specified' do
        let!(:pipeline) { create(:ci_pipeline, project: project) }
        let!(:dependency) { create(:ci_build, :success, pipeline: pipeline) }

        let(:dependencies) do
          [{ pipeline: pipeline.id.to_s, job: dependency.name, artifacts: true }]
        end

        it 'ignores jobs from the current pipeline as simple needs should be used instead' do
          expect(cross_pipeline_deps).to be_empty
        end

        it { is_expected.not_to be_valid }
      end
    end

    context 'when artifacts:false' do
      let!(:pipeline) { create(:ci_pipeline, child_of: parent_pipeline) }
      let!(:parent_pipeline) { create(:ci_pipeline, project: project) }
      let!(:parent_job) { create(:ci_build, :success, name: 'parent_job', pipeline: parent_pipeline) }

      let(:dependencies) do
        [{ pipeline: parent_pipeline.id.to_s, job: parent_job.name, artifacts: false }]
      end

      it { expect(cross_pipeline_deps).to be_empty }
      it { is_expected.to be_valid } # we simply ignore it
    end
  end

  describe '#all' do
    let!(:job) do
      create(:ci_build, pipeline: pipeline, name: 'deploy', stage_idx: 3, stage: 'deploy')
    end

    let(:dependencies) { described_class.new(job) }

    subject { dependencies.all }

    it 'returns the union of all local dependencies and any cross project dependencies' do
      expect(dependencies).to receive(:local).and_return([1, 2, 3])
      expect(dependencies).to receive(:cross_project).and_return([3, 4])

      expect(subject).to contain_exactly(1, 2, 3, 4)
    end
  end
end
