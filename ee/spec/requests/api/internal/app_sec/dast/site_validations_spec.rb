# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Internal::AppSec::Dast::SiteValidations do
  let_it_be(:project) { create(:project) }
  let_it_be(:developer) { create(:user, developer_projects: [project]) }

  describe 'PUT /internal/dast/site_validations/:id' do
    context 'when authenticated' do
      context 'state transitions' do
        let_it_be(:site_validation) { create(:dast_site_validation) }

        context 'when the state transition is invalid' do
          it 'returns 400 and an error message', :aggregate_failures do
            put api("/internal/dast/site_validations/#{site_validation.id}", developer), params: { state: 'pass' }

            expect(response).to have_gitlab_http_status(:bad_request)
            expect(json_response).to eq('message' => 'Could not update DAST site validation')
          end
        end
      end
    end
  end
end
