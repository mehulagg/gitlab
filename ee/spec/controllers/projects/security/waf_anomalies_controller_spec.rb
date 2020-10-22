# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::WafAnomaliesController do
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:user) }

  let_it_be(:project) { create(:project, :public, :repository, group: group) }
  let_it_be(:environment) { create(:environment, :with_review_app, project: project) }
  let_it_be(:cluster) { create(:cluster, :provided_by_gcp, environment_scope: '*', projects: [environment.project]) }

  let_it_be(:action_params) { { project_id: project, namespace_id: project.namespace, environment_id: environment } }

  let(:es_client) { nil }

  describe 'GET #summary' do
    subject { get :summary, params: action_params, format: :json }

    before do
      stub_licensed_features(threat_monitoring: true)

      sign_in(user)

      allow_next_instance_of(::Security::WafAnomalySummaryService) do |instance|
        allow(instance).to receive(:elasticsearch_client).at_most(3).times { es_client }
        allow(instance).to receive(:chart_above_v3?) { true }
      end
    end

    context 'with authorized user' do
      before do
        group.add_developer(user)
      end

      context 'with elastic_stack' do
        let(:es_client) { double(Elasticsearch::Client) }

        before do
          allow(es_client).to receive(:msearch) { { "responses" => [{}, {}] } }
        end

        it 'returns anomaly summary' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['total_traffic']).to eq(0)
          expect(json_response['anomalous_traffic']).to eq(0)
          expect(response).to match_response_schema('vulnerabilities/summary', dir: 'ee')
        end
      end

      context 'without elastic_stack' do
        it 'returns not found' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end

      it 'sets a polling interval header' do
        subject

        expect(response.headers['Poll-Interval']).to eq('5000')
      end
    end

    context 'with unauthorized user' do
      it 'returns unauthorized' do
        subject

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end
end
