# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DAST.gitlab-ci.yml' do
  subject(:template) { Gitlab::Template::GitlabCiYmlTemplate.find('DAST') }

  describe 'the created pipeline' do
    let(:user) { create(:admin) }
    let(:default_branch) { 'master' }
    let(:pipeline_branch) { default_branch }
    let(:project) { create(:project, :custom_repo, files: { 'README.txt' => '' }) }
    let(:service) { Ci::CreatePipelineService.new(project, user, ref: pipeline_branch ) }
    let(:pipeline) { service.execute!(:push) }
    let(:build_names) { pipeline.builds.pluck(:name) }

    before do
      stub_ci_pipeline_yaml_file(template.content)
      allow_any_instance_of(Ci::BuildScheduleWorker).to receive(:perform).and_return(true)
      allow(project).to receive(:default_branch).and_return(default_branch)
    end

    context 'when project has no license' do
      it 'includes no jobs' do
        expect { pipeline }.to raise_error(Ci::CreatePipelineService::CreateError)
      end
    end

    context 'when project has Ultimate license' do
      let(:license) { create(:license, plan: License::ULTIMATE_PLAN) }
      let(:cluster) { create(:cluster, :project, :provided_by_gcp, projects: [project]) }

      before do
        allow(License).to receive(:current).and_return(license)
      end

      context 'by default' do
        before do
          allow(cluster).to receive(:active?).and_return(true)
        end

        it 'includes job' do
          expect(build_names).to match_array(%w[dast])
        end
      end

      context 'when cluster is not active' do
        context 'by default' do
          it 'includes no jobs' do
            expect { pipeline }.to raise_error(Ci::CreatePipelineService::CreateError)
          end
        end

        context 'when DAST_WEBSITE is present' do
          before do
            create(:ci_variable, project: project, key: 'DAST_WEBSITE', value: 'http://example.com')
          end

          it 'includes job' do
            expect(build_names).to match_array(%w[dast])
          end
        end

        context 'when DAST_API_SPECIFICATION is present' do
          before do
            create(:ci_variable, project: project, key: 'DAST_API_SPECIFICATION', value: 'http://my.api/api-specification.yml')
          end

          it 'includes job' do
            expect(build_names).to match_array(%w[dast])
          end
        end
      end

      context 'when DAST_DISABLED=1' do
        before do
          allow(cluster).to receive(:active?).and_return(true)

          create(:ci_variable, project: project, key: 'DAST_DISABLED', value: '1')
        end

        it 'includes no jobs' do
          expect { pipeline }.to raise_error(Ci::CreatePipelineService::CreateError)
        end
      end

      context 'when DAST_DISABLED_FOR_DEFAULT_BRANCH=1' do
        before do
          allow(cluster).to receive(:active?).and_return(true)

          create(:ci_variable, project: project, key: 'DAST_DISABLED_FOR_DEFAULT_BRANCH', value: '1')
        end

        context 'when on default branch' do
          it 'includes no jobs' do
            expect { pipeline }.to raise_error(Ci::CreatePipelineService::CreateError)
          end
        end

        context 'when on feature branch' do
          let(:pipeline_branch) { 'patch-1' }

          before do
            project.repository.create_branch(pipeline_branch)
          end

          it 'includes job' do
            expect(build_names).to match_array(%w[dast])
          end
        end
      end

      context 'when REVIEW_DISABLED=true' do
        before do
          allow(cluster).to receive(:active?).and_return(true)

          create(:ci_variable, project: project, key: 'REVIEW_DISABLED', value: 'true')
        end

        context 'when on default branch' do
          it 'includes job' do
            expect(build_names).to match_array(%w[dast])
          end
        end

        context 'when on feature branch' do
          let(:pipeline_branch) { 'patch-1' }

          before do
            project.repository.create_branch(pipeline_branch)
          end

          it 'includes no jobs' do
            expect { pipeline }.to raise_error(Ci::CreatePipelineService::CreateError)
          end
        end
      end
    end
  end
end
