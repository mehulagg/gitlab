# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting test reports of a requirement' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:requirement) { create(:requirement, project: project) }
  let_it_be(:test_report_1) { create(:test_report, requirement: requirement, created_at: 3.days.from_now) }
  let_it_be(:test_report_2) { create(:test_report, requirement: requirement, created_at: 2.days.from_now) }

  let(:test_reports_data) { graphql_data['project']['requirements']['edges'][0]['node']['testReports']['edges'] }
  let(:fields) do
    <<~QUERY
    edges {
      node {
        testReports {
          edges {
            node {
              #{all_graphql_fields_for('test_reports'.classify)}
            }
          }
        }
      }
    }
    QUERY
  end

  let(:query) do
    graphql_query_for(
      'project',
      { 'fullPath' => project.full_path },
      query_graphql_field('requirements', {}, fields)
    )
  end

  before do
    stub_licensed_features(requirements: true)
  end

  context 'when user can read requirement' do
    before do
      project.add_developer(current_user)
    end

    it_behaves_like 'a working graphql query' do
      before do
        post_graphql(query, current_user: current_user)
      end
    end

    it 'returns test reports successfully' do
      post_graphql(query, current_user: current_user)

      test_reports_ids = test_reports_data.map { |result| result['node']['id'] }
      expected_results = [test_report_1.to_global_id.to_s, test_report_2.to_global_id.to_s]
      expect(test_reports_ids).to match_array(expected_results)
    end

    context 'with pagination' do
      let_it_be(:data_path) { [:project, :requirement, :testReports] }
      let_it_be(:test_report_3) { create(:test_report, requirement: requirement, created_at: 4.days.ago) }

      def pagination_query(params, page_info)
        graphql_query_for(
          'project',
          { 'fullPath' => project.full_path },
          "requirement { testReports(#{params}) { #{page_info} edges { node { id } } } }"
        )
      end

      def pagination_results_data(data)
        data.map { |test_report| test_report.dig('node', 'id') }
      end

      it_behaves_like 'sorted paginated query' do
        let(:sort_param)       { 'created_asc' }
        let(:first_param)      { 2 }
        let(:expected_results) do
          [
            test_report_3.to_global_id.to_s,
            test_report_2.to_global_id.to_s,
            test_report_1.to_global_id.to_s
          ]
        end
      end
    end
  end

  context 'when the user does not have access to the requirement' do
    it 'returns nil' do
      post_graphql(query)

      expect(graphql_data['project']).to be_nil
    end
  end
end
