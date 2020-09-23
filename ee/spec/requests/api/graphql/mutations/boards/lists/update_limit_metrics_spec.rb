# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Update list limit metrics' do
  include GraphqlHelpers

  let_it_be(:group) { create(:group, :private) }
  let_it_be(:board) { create(:board, group: group) }
  let_it_be(:user)  { create(:user) }
  let_it_be(:list)  { create(:list, board: board) }

  let(:mutation_class) { Mutations::Boards::Lists::UpdateLimitMetrics }
  let(:mutation_name) { mutation_class.graphql_name }
  let(:mutation_result_identifier) { mutation_name.camelize(:lower) }

  before_all do
    group.add_maintainer(user)
  end

  it 'returns an error if the user is not allowed to update the issue' do
    post_graphql_mutation(mutation('all_metrics'), current_user: create(:user))

    expect(graphql_errors).to include(a_hash_including('message' => "The resource that you are attempting to access does " \
     "not exist or you don't have permission to perform this action"))
  end

  it 'returns an error if the list cannot be found' do
    list_gid = ::URI::GID.parse("gid://#{GlobalID.app}/List/0")

    post_graphql_mutation(mutation('all_metrics', list_id: list_gid), current_user: create(:user))

    expect(graphql_errors).to include(a_hash_including('message' => "The resource that you are attempting to access does " \
     "not exist or you don't have permission to perform this action"))
  end

  it 'returns an error if the gid identifies another object' do
    post_graphql_mutation(mutation('all_metrics', list_id: user.to_global_id.to_s), current_user: create(:user))

    expect(graphql_errors).to include(a_hash_including('message' => "The resource that you are attempting to access does " \
     "not exist or you don't have permission to perform this action"))
  end

  %w[all_metrics issue_count issue_weights].each do |metric|
    it "updates the list limit metrics for limit metric #{metric}" do
      post_graphql_mutation(mutation(metric), current_user: user)

      expect(response).to have_gitlab_http_status(:success)

      response_list = json_response['data'][mutation_result_identifier]['list']
      expect(response_list['id']).to eq(list.to_global_id.to_s)
      expect(response_list['limitMetric']).to eq(metric.to_s)
      expect(response_list['maxIssueCount']).to eq(3)
      expect(response_list['maxIssueWeight']).to eq(42)

      expect_list_update(list, metric: metric, count: 3, weight: 42)
    end
  end

  def list_update_params(metric)
    {
      list_id: list.to_global_id.to_s,
      limit_metric: metric,
      max_issue_count: 3,
      max_issue_weight: 42
    }
  end

  def mutation(metric, additional_params = {})
    graphql_mutation(mutation_name, list_update_params(metric).merge(additional_params),
                     <<-QL.strip_heredoc
                       clientMutationId
                       list {
                         id, maxIssueCount, maxIssueWeight, limitMetric
                       }
                       errors
    QL
    )
  end

  def expect_list_update(list, metric:, count:, weight:)
    reloaded_list = list.reload

    expect(reloaded_list.limit_metric).to eq(metric)
    expect(reloaded_list.max_issue_count).to eq(count)
    expect(reloaded_list.max_issue_weight).to eq(weight)
  end
end
