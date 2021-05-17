# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Internal::AppSec::Dast::SiteValidations do
  let_it_be(:project) { create(:project) }
  let_it_be(:developer) { create(:user, developer_projects: [project]) }
  let_it_be(:site_validation) { create(:dast_site_validation, dast_site_token: create(:dast_site_token, project: project)) }

  describe 'PUT /internal/dast/site_validations/:id/transition' do
    let(:url) { "/internal/dast/site_validations/#{site_validation.id}/transition" }

    context 'when licensed feature is not available' do
      it 'returns 401 and an error message', :aggregate_failures do
        put api(url, developer), params: { event: :pass }

        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(json_response).to eq('message' => '401 Unauthorized')
      end
    end

    context 'when licensed feature is available' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
      end

      context 'when authenticated' do
        context 'when not authorized' do
          it 'returns 401 and an error message', :aggregate_failures do
            put api(url, create(:user)), params: { event: :pass }

            expect(response).to have_gitlab_http_status(:unauthorized)
            expect(json_response).to eq('message' => '401 Unauthorized')
          end
        end

        context 'when authorized' do
          context 'when site validation does not exist' do
            let_it_be(:site_validation) { build(:dast_site_validation, id: non_existing_record_id) }

            it 'returns 400 and an error message', :aggregate_failures do
              put api(url, developer), params: { event: :pass }

              expect(response).to have_gitlab_http_status(:not_found)
              expect(json_response).to eq('message' => '404 Not found')
            end
          end

          context 'when site validation exists' do
            context 'state transitions' do
              context 'when the state transition is invalid' do
                it 'returns 400 and an error message', :aggregate_failures do
                  put api(url, developer), params: { event: :pass }

                  expect(response).to have_gitlab_http_status(:bad_request)
                  expect(json_response).to eq('message' => 'Could not update DAST site validation')
                end
              end

              shared_examples 'it transitions' do |event|
                it "calls the underlying transition method: ##{event}", :aggregate_failures do
                  expect(DastSiteValidation).to receive(:find).with(String(site_validation.id)).and_return(site_validation)
                  expect(site_validation).to receive(event).and_return(true)

                  put api(url, developer), params: { event: event }
                end
              end

              it_behaves_like 'it transitions', :start
              it_behaves_like 'it transitions', :fail_op
              it_behaves_like 'it transitions', :retry
              it_behaves_like 'it transitions', :pass
            end
          end
        end
      end
    end
  end
end
