# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Internal::AppSec::Dast::SiteValidations do
  let_it_be(:project) { create(:project) }
  let_it_be(:developer) { create(:user, developer_projects: [project]) }
  let_it_be(:site_validation) { create(:dast_site_validation, dast_site_token: create(:dast_site_token, project: project)) }
  let_it_be(:job) { create(:ci_build, :running, user: developer) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  describe 'PUT /internal/dast/site_validations/:id/transition' do
    let(:event_param) { :pass }
    let(:params) { { event: event_param } }
    let(:headers) { {} }

    subject do
      put api("/internal/dast/site_validations/#{site_validation.id}/transition"), params: params, headers: headers
    end

    context 'when a valid job token header is not set' do
      it 'returns 401 and an error message', :aggregate_failures do
        subject

        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(json_response).to eq('message' => '401 Unauthorized')
      end
    end

    context 'when a valid job token header is set' do
      let(:headers) { { API::Helpers::Runner::JOB_TOKEN_HEADER => job.token } }

      context 'when user does not have access to the site validation' do
        let(:job) { create(:ci_build, :running, user: create(:user)) }

        it 'returns 403 and an error message', :aggregate_failures do
          subject

          expect(response).to have_gitlab_http_status(:forbidden)
          expect(json_response).to eq('message' => '403 Forbidden')
        end
      end

      context 'when user has access to the site validation' do
        context 'when licensed feature is not available' do
          before do
            stub_licensed_features(security_on_demand_scans: false)
          end

          it 'returns 403 and an error message', :aggregate_failures do
            subject

            expect(response).to have_gitlab_http_status(:forbidden)
            expect(json_response).to eq('message' => '403 Forbidden')
          end
        end

        context 'when site validation does not exist' do
          let_it_be(:site_validation) { build(:dast_site_validation, id: non_existing_record_id) }

          it 'returns 404 and an error message', :aggregate_failures do
            subject

            expect(response).to have_gitlab_http_status(:not_found)
            expect(json_response).to eq('message' => '404 Not found')
          end
        end

        context 'when site validation exists' do
          context 'when the state transition is invalid' do
            it 'returns 400 and an error message', :aggregate_failures do
              subject

              expect(response).to have_gitlab_http_status(:bad_request)
              expect(json_response).to eq('message' => '400 Bad request - Could not update DAST site validation')
            end
          end

          shared_examples 'it transitions' do |event|
            let(:event_param) { event }

            it "calls the underlying transition method: ##{event}", :aggregate_failures do
              expect(DastSiteValidation).to receive(:find).with(String(site_validation.id)).and_return(site_validation)
              expect(site_validation).to receive(event).and_return(true)

              subject
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
