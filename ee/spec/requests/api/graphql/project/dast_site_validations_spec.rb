# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.project(fullPath).dastSiteValidations' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:dast_site_token) { create(:dast_site_token, project: project, url: generate(:url)) }
  let_it_be(:dast_site_validation1) { create(:dast_site_validation, dast_site_token: dast_site_token) }
  let_it_be(:dast_site_validation2) { create(:dast_site_validation, dast_site_token: dast_site_token) }
  let_it_be(:dast_site_validation3) { create(:dast_site_validation, dast_site_token: dast_site_token) }
  let_it_be(:dast_site_validation4) { create(:dast_site_validation, dast_site_token: dast_site_token) }
  let_it_be(:current_user) { create(:user) }

  let(:query) do
    fields = all_graphql_fields_for('DastSiteValidation')

    graphql_query_for(
      'project',
      { 'fullPath' => project.full_path },
      query_graphql_field('dastSiteValidations', 'first: 3', "edges { node { #{fields} } }")
    )
  end

  let(:project_response) { subject['project'] }
  let(:dast_site_validations_response) { project_response&.[]('dastSiteValidations') }
  let(:edges) { dast_site_validations_response&.[]('edges') }

  subject do
    post_graphql(
      query,
      current_user: current_user,
      variables: {
        fullPath: project.full_path
      }
    )
    graphql_data
  end

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  context 'when a user does not have access to the project' do
    it 'returns a null project' do
      expect(project_response).to be_nil
    end
  end

  context 'when a user does not have access to dast_site_validations' do
    it 'returns an empty edges array' do
      project.add_guest(current_user)

      expect(edges).to be_empty
    end
  end

  context 'when a user has access to dast_site_validations' do
    before do
      project.add_developer(current_user)
    end

    let(:expected_results) do
      [
        dast_site_validation4,
        dast_site_validation3,
        dast_site_validation2
      ].map { |validation| global_id_of(validation)}
    end

    it 'returns a populated edges array containing the correct dast_site_validations' do
      results = edges.map { |edge| edge['node']['id'] }

      expect(results).to eq(expected_results)
    end
  end
end
