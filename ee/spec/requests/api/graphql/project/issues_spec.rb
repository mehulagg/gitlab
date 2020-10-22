# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting an issue list for a project' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }

  describe 'sorting and pagination' do
    let(:sort_project) { create(:project, :public) }
    let(:data_path)    { [:project, :issues] }

    def pagination_query(params, page_info)
      graphql_query_for(
        'project',
        { 'fullPath' => sort_project.full_path },
        query_graphql_field('issues', params, "#{page_info} edges { node { iid weight} }")
      )
    end

    def pagination_results_data(data)
      data.map { |issue| issue.dig('node', 'iid').to_i }
    end

    context 'when sorting by weight' do
      let!(:weight_issue1) { create(:issue, project: sort_project, weight: 5) }
      let!(:weight_issue2) { create(:issue, project: sort_project, weight: nil) }
      let!(:weight_issue3) { create(:issue, project: sort_project, weight: 1) }
      let!(:weight_issue4) { create(:issue, project: sort_project, weight: nil) }
      let!(:weight_issue5) { create(:issue, project: sort_project, weight: 3) }

      context 'when ascending' do
        it_behaves_like 'sorted paginated query' do
          let(:sort_param)       { 'WEIGHT_ASC' }
          let(:first_param)      { 2 }
          let(:expected_results) { [weight_issue3.iid, weight_issue5.iid, weight_issue1.iid, weight_issue4.iid, weight_issue2.iid] }
        end
      end

      context 'when descending' do
        it_behaves_like 'sorted paginated query' do
          let(:sort_param)       { 'WEIGHT_DESC' }
          let(:first_param)      { 2 }
          let(:expected_results) { [weight_issue1.iid, weight_issue5.iid, weight_issue3.iid, weight_issue4.iid, weight_issue2.iid] }
        end
      end
    end
  end

  describe 'blocked' do
    let_it_be(:group) { create(:group, :public) }
    let_it_be(:project) { create(:project, namespace: group) }
    let_it_be(:unrelated_issue) { create(:issue, project: project) }
    let_it_be(:blocked_issue1) { create(:issue, project: project) }
    let_it_be(:blocking_issue1) { create(:issue, project: project) }
    let_it_be(:blocked_issue2) { create(:issue, project: project) }
    let_it_be(:blocking_issue2) { create(:issue, :confidential, project: project) }

    let_it_be(:issue_link1) { create(:issue_link, source: blocked_issue1, target: blocking_issue1, link_type: 'is_blocked_by') }
    let_it_be(:issue_link2) { create(:issue_link, source: blocking_issue2, target: blocked_issue2, link_type: 'blocks') }

    let(:query) do
      graphql_query_for('project', { fullPath: project.full_path }, query_graphql_field('issues', {}, issue_links_aggregates_query))
    end

    let(:single_issue_query) do
      graphql_query_for('project', { fullPath: project.full_path }, query_graphql_field('issues', { iid: blocked_issue1.iid.to_s }, issue_links_aggregates_query))
    end

    let(:issue_links_aggregates_query) do
      <<~QUERY
        nodes {
          id
          blocked
        }
      QUERY
    end

    before do
      group.add_developer(current_user)
    end

    context 'working query' do
      before do
        post_graphql(single_issue_query, current_user: current_user)
      end

      it_behaves_like 'a working graphql query'
    end

    it 'uses the LazyBlockAggregate service' do
      expect(::Gitlab::Graphql::Aggregations::Issues::LazyBlockAggregate).to receive(:new)

      post_graphql(single_issue_query, current_user: current_user)
    end

    it 'returns the correct results', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      result = graphql_data.dig('project', 'issues', 'nodes')

      expect(find_result(result, blocked_issue1)).to eq true
      expect(find_result(result, blocked_issue2)).to eq true
      expect(find_result(result, blocking_issue1)).to eq false
      expect(find_result(result, blocking_issue2)).to eq false
    end
  end

  def find_result(result, issue)
    result.find { |r| r['id'] == issue.to_global_id.to_s }['blocked']
  end
end
