# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.project(fullPath).dastSiteValidation' do
  include GraphqlHelpers

  let_it_be(:dast_site_validation) { create(:dast_site_validation) }
  let_it_be(:project) { dast_site_validation.dast_site_token.project }
  let_it_be(:current_user) { create(:user) }

  let(:query) do
    %(
      query project($fullPath: ID!, $targetUrl: String!) {
        project(fullPath: $fullPath) {
          dastSiteValidation(targetUrl: $targetUrl) {
            id
            status
          }
        }
      }
    )
  end

  subject do
    post_graphql(
      query,
      current_user: current_user,
      variables: {
        fullPath: project.full_path,
        targetUrl: dast_site_validation.url_base
      }
    )
    graphql_data
  end

  let(:project_response) { subject['project'] }
  let(:dast_site_validation_response) { project_response['dastSiteValidation'] }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  context 'when a user does not have access to the project' do
    it 'returns a null project' do
      expect(project_response).to be_nil
    end
  end

  context 'when a user does not have access to dast_site_validation' do
    it 'returns a null dast_site_validation' do
      project.add_guest(current_user)

      expect(dast_site_validation_response).to be_nil
    end
  end

  context 'when a user has access to dast_site_profiles' do
    before do
      project.add_developer(current_user)
    end

    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(security_on_demand_scans_site_validation: false)
      end

      it 'returns populated edges array' do
        subject
        expect(graphql_errors.first['message']).to eq("Feature disabled")
      end
    end

    it 'returns a dast_site_validation' do
      expect(dast_site_validation_response['id']).to eq(dast_site_validation.to_global_id.to_s)
      expect(dast_site_validation_response['status']).to eq('PENDING_VALIDATION')
    end

    context 'when there are multiple DAST site validations with the same target and for the same project' do
      it 'returns the most recent dast_site_validation' do
        new_dast_site_validation = create(:dast_site_validation, dast_site_token: dast_site_validation.dast_site_token)

        expect(dast_site_validation_response['id']).to eq(new_dast_site_validation.to_global_id.to_s)
      end
    end
  end
end
