# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Internal::UpcomingReconciliations, :api do
  describe 'PUT /internal/upcoming_reconciliations' do
    before do
      stub_application_setting(check_namespace_plan: true)
    end

    context 'when unauthenticated' do
      it 'returns authentication error' do
        put api('/internal/upcoming_reconciliations')

        expect(response).to have_gitlab_http_status(:unauthorized)
      end
    end

    context 'when authenticated as user' do
      let_it_be(:user) { create(:user) }

      it 'returns authentication error' do
        put api('/internal/upcoming_reconciliations', user)

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'when authenticated as admin' do
      let_it_be(:admin) { create(:admin) }
      let_it_be(:namespace) { create(:namespace) }

      let(:namespace_id) { namespace.id }
      let(:upcoming_reconciliations) do
        [{
           namespace_id: namespace_id,
           next_reconciliation_date: Date.today + 5.days,
           display_alert_from: Date.today - 2.days
         }]
      end

      subject(:put_upcoming_reconciliations) do
        put api('/internal/upcoming_reconciliations', admin), params: { upcoming_reconciliations: upcoming_reconciliations }
      end

      it 'returns success' do
        put_upcoming_reconciliations

        expect(response).to have_gitlab_http_status(:ok)
      end

      context 'when namespace_id is empty' do
        let(:namespace_id) { nil }

        it 'returns error', :aggregate_failures do
          put_upcoming_reconciliations

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(json_response.dig('error')).to eq('upcoming_reconciliations[namespace_id] is empty')
        end
      end

      context 'when update service failed' do
        let(:error_message) { 'update_service_error' }

        before do
          allow_next_instance_of(::UpcomingReconciliations::UpdateService) do |service|
            allow(service).to receive(:execute).and_return(ServiceResponse.error(message: error_message))
          end
        end

        it 'returns error', :aggregate_failures do
          put_upcoming_reconciliations

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(json_response.dig('message', 'error')).to eq(error_message)
        end
      end
    end

    context 'when not gitlab.com', :aggregate_failures do
      it 'returns 403 error' do
        stub_application_setting(check_namespace_plan: false)

        put api('/internal/upcoming_reconciliations')

        expect(response).to have_gitlab_http_status(:forbidden)
        expect(json_response.dig('message')).to eq('403 Forbidden - This API is gitlab.com only!')
      end
    end
  end
end
