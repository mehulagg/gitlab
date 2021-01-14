# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.project(fullPath).dastSiteValidations' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:dast_scan1) { create(:dast_scan, project: project) }
  let_it_be(:dast_scan2) { create(:dast_scan, project: project) }
  let_it_be(:dast_scan3) { create(:dast_scan, project: project) }
  let_it_be(:dast_scan4) { create(:dast_scan, project: project) }

  subject do
    fields = all_graphql_fields_for('DastScan')

    query = graphql_query_for(
      :project,
      { full_path: project.full_path },
      query_nodes(:dast_scans, fields)
    )

    post_graphql(
      query,
      current_user: current_user,
      variables: {
        fullPath: project.full_path
      }
    )
  end

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  context 'when a user does not have access to the project' do
    it 'returns a null project' do
      subject

      expect(graphql_data_at(:project)).to be_nil
    end
  end

  context 'when a user does not have access to dast_scans' do
    it 'returns an empty nodes array' do
      project.add_guest(current_user)

      subject

      expect(graphql_data_at(:project, :dast_scans, :nodes)).to be_empty
    end
  end

  context 'when a user has access to dast_scans' do
    before do
      project.add_developer(current_user)
    end

    let(:data_path) { [:project, :dast_scans] }

    def pagination_results_data(dast_scans)
      dast_scans.map { |dast_scan| dast_scan['id'] }
    end

    it_behaves_like 'sorted paginated query' do
      let(:sort_param) { nil }
      let(:first_param) { 3 }

      let(:expected_results) do
        [dast_scan4, dast_scan3, dast_scan2, dast_scan1].map { |validation| global_id_of(validation)}
      end
    end
  end

  def pagination_query(arguments)
    graphql_query_for(
      :project,
      { full_path: project.full_path },
      query_nodes(:dast_scans, 'id', include_pagination_info: true, args: arguments)
    )
  end
end
