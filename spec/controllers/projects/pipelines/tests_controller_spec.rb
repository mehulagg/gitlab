# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Pipelines::TestsController do
  let(:user) { create(:user) }
  let(:project) { create(:project, :public, :repository) }
  let(:pipeline) { create(:ci_pipeline, project: project) }

  before do
    sign_in(user)
  end

  describe 'GET #summary.json' do
    context 'when pipeline has build report results' do
      let(:pipeline) { create(:ci_pipeline, :with_report_results, project: project) }

      it 'renders test report summary data' do
        get_tests_summary_json

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response['total_count']).to eq(2)
      end
    end

    context 'when pipeline does not have build report results' do
      it 'renders test report summary data' do
        get_tests_summary_json

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response['total_count']).to eq(0)
      end
    end

    context 'when feature is disabled' do
      before do
        stub_feature_flags(build_report_summary: false)
      end

      it 'returns 404' do
        get_tests_summary_json

        expect(response).to have_gitlab_http_status(:not_found)
        expect(response.body).to be_empty
      end
    end
  end

  def get_tests_summary_json
    get :summary,
      params: {
        namespace_id: project.namespace,
        project_id: project,
        id: pipeline.id
      },
      format: :json
  end
end
