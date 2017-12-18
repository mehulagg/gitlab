require 'spec_helper'

describe Ci::Build do
  let(:project) { create(:project, :repository) }

  let(:pipeline) do
    create(:ci_pipeline, project: project,
                         sha: project.commit.id,
                         ref: project.default_branch,
                         status: 'success')
  end

  let(:job) { create(:ci_build, pipeline: pipeline) }

  describe '.codequality' do
    subject { described_class.codequality }

    context 'when a job name is codequality' do
      let!(:job) { create(:ci_build, pipeline: pipeline, name: 'codequality') }

      it { is_expected.to include(job) }
    end

    context 'when a job name is codeclimate' do
      let!(:job) { create(:ci_build, pipeline: pipeline, name: 'codeclimate') }

      it { is_expected.to include(job) }
    end

    context 'when a job name is irrelevant' do
      let!(:job) { create(:ci_build, pipeline: pipeline, name: 'codechecker') }

      it { is_expected.not_to include(job) }
    end
  end

  describe '.no_old_trace' do
    subject { described_class.no_old_trace }

    let!(:job) { create(:ci_build) }

    context 'when the trace attribute is not null' do
      before do
        job.update_column(:trace, 'data')
      end

      it { is_expected.not_to include(job) }
    end

    context 'when the trace attribute is null' do
      it { is_expected.to include(job) }
    end
  end

  describe '.not_erased' do
    subject { described_class.not_erased }

    context 'when the build is erasable' do
      let!(:job) { create(:ci_build, :success, :trace) }

      context 'when the build was erased' do
        before do
          job.erase
        end

        it { is_expected.not_to include(job) }
      end

      context 'when the build was not erased' do
        it { is_expected.to include(job) }
      end
    end

    context 'when the build is not erasable' do
      let!(:job) { create(:ci_build, :running, :trace) }

      it { is_expected.to include(job) }
    end
  end

  describe '#shared_runners_minutes_limit_enabled?' do
    subject { job.shared_runners_minutes_limit_enabled? }

    context 'for shared runner' do
      before do
        job.runner = create(:ci_runner, :shared)
      end

      it do
        expect(job.project).to receive(:shared_runners_minutes_limit_enabled?)
          .and_return(true)

        is_expected.to be_truthy
      end
    end

    context 'with specific runner' do
      before do
        job.runner = create(:ci_runner, :specific)
      end

      it { is_expected.to be_falsey }
    end

    context 'without runner' do
      it { is_expected.to be_falsey }
    end
  end

  context 'updates pipeline minutes' do
    let(:job) { create(:ci_build, :running, pipeline: pipeline) }

    %w(success drop cancel).each do |event|
      it "for event #{event}" do
        expect(UpdateBuildMinutesService)
          .to receive(:new).and_call_original

        job.public_send(event)
      end
    end
  end

  describe '#stick_build_if_status_changed' do
    it 'sticks the build if the status changed' do
      job = create(:ci_build, :pending)

      allow(Gitlab::Database::LoadBalancing).to receive(:enable?)
        .and_return(true)

      expect(Gitlab::Database::LoadBalancing::Sticking).to receive(:stick)
        .with(:build, job.id)

      job.update(status: :running)
    end
  end

  describe '#variables' do
    subject { job.variables }

    context 'when environment specific variable is defined' do
      let(:environment_varialbe) do
        { key: 'ENV_KEY', value: 'environment', public: false }
      end

      before do
        job.update(environment: 'staging')
        create(:environment, name: 'staging', project: job.project)

        variable =
          build(:ci_variable,
                environment_varialbe.slice(:key, :value)
                  .merge(project: project, environment_scope: 'stag*'))

        variable.save!
      end

      context 'when variable environment scope is available' do
        before do
          stub_licensed_features(variable_environment_scope: true)
        end

        it { is_expected.to include(environment_varialbe) }
      end

      context 'when variable environment scope is not available' do
        before do
          stub_licensed_features(variable_environment_scope: false)
        end

        it { is_expected.not_to include(environment_varialbe) }
      end
    end
  end

  ARTIFACTS_METHODS = {
    has_codeclimate_json?: Ci::Build::CODEQUALITY_FILE,
    has_performance_json?: Ci::Build::PERFORMANCE_FILE,
    has_sast_json?: Ci::Build::SAST_FILE,
    has_clair_json?: Ci::Build::CLAIR_FILE
  }.freeze

  ARTIFACTS_METHODS.each do |method, filename|
    describe "##{method}" do
      context 'valid build' do
        let!(:build) do
          create(
            :ci_build,
            :artifacts,
            pipeline: pipeline,
            options: {
              artifacts: {
                paths: [filename]
              }
            }
          )
        end

        it { expect(build.send(method)).to be_truthy }
      end

      context 'invalid build' do
        let!(:build) do
          create(
            :ci_build,
            :artifacts,
            pipeline: pipeline,
            options: {}
          )
        end

        it { expect(build.send(method)).to be_falsey }
      end
    end
  end

  describe '#erase' do
    context "when the build is erasable (it doesn't actually erase the trace either)" do
      let(:build) { create(:ci_build, :running, :trace) }

      it 'does not instantiate ::Geo::BuildErasedEventStore' do
        expect(::Geo::BuildErasedEventStore).not_to receive(:new)

        build.erase
      end
    end

    context 'when the build is not erasable' do
      let(:build) { create(:ci_build, :success, :trace) }

      it 'calls ::Geo::BuildErasedEventStore#create' do
        store = double(:event_store)
        expect(store).to receive(:create)
        expect(::Geo::BuildErasedEventStore).to receive(:new).and_return(store)

        build.erase
      end
    end
  end
end
