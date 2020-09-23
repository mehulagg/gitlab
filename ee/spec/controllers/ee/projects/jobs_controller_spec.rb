# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::JobsController do
  describe 'GET #show', :clean_gitlab_redis_shared_state do
    context 'when requesting JSON' do
      let_it_be(:user) { create(:user) }
      let(:merge_request) { create(:merge_request, source_project: project) }
      let(:runner) { create(:ci_runner, :instance, description: 'Shared runner') }
      let(:pipeline) { create(:ci_pipeline, project: project) }
      let(:job) { create(:ci_build, :success, :artifacts, pipeline: pipeline, runner: runner) }

      before do
        project.add_developer(user)
        sign_in(user)

        allow_next_instance_of(Ci::Build) do |instance|
          allow(instance).to receive(:merge_request).and_return(merge_request)
        end
      end

      context 'with shared runner that has quota' do
        let(:project) { create(:project, :repository, :private, shared_runners_enabled: true) }

        before do
          stub_application_setting(shared_runners_minutes: 2)

          get_show(id: job.id, format: :json)
        end

        it 'exposes quota information' do
          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to match_response_schema('job/job_details', dir: 'ee')
          expect(json_response['runners']['quota']['used']).to eq 0
          expect(json_response['runners']['quota']['limit']).to eq 2
        end
      end

      context 'with shared runner quota exceeded' do
        let(:group) { create(:group, :with_used_build_minutes_limit) }
        let(:project) { create(:project, :repository, namespace: group, shared_runners_enabled: true) }

        before do
          get_show(id: job.id, format: :json)
        end

        it 'exposes quota information' do
          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to match_response_schema('job/job_details', dir: 'ee')
          expect(json_response['runners']['quota']['used']).to eq 1000
          expect(json_response['runners']['quota']['limit']).to eq 500
        end
      end

      context 'when shared runner has no quota' do
        let(:project) { create(:project, :repository, :private, shared_runners_enabled: true) }

        before do
          stub_application_setting(shared_runners_minutes: 0)

          get_show(id: job.id, format: :json)
        end

        it 'does not exposes quota information' do
          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to match_response_schema('job/job_details', dir: 'ee')
          expect(json_response['runners']).not_to have_key('quota')
        end
      end

      context 'when project is public' do
        let(:project) { create(:project, :repository, :public, shared_runners_enabled: true) }

        before do
          stub_application_setting(shared_runners_minutes: 2)

          get_show(id: job.id, format: :json)
        end

        it 'exposes quota information' do
          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to match_response_schema('job/job_details', dir: 'ee')
          expect(json_response['runners']['quota']['used']).to eq 0
          expect(json_response['runners']['quota']['limit']).to eq 2
        end
      end
    end

    private

    def get_show(**extra_params)
      params = {
          namespace_id: project.namespace.to_param,
          project_id: project
      }

      get :show, params: params.merge(extra_params)
    end
  end
end
