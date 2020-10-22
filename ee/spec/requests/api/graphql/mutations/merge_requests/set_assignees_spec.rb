# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Setting assignees of a merge request' do
  include GraphqlHelpers

  let(:current_user) { create(:user) }
  let(:merge_request) { create(:merge_request) }
  let(:project) { merge_request.project }
  let(:assignees) { create_list(:user, 3) }
  let(:extra_assignees) { create_list(:user, 2) }
  let(:input) { { assignee_usernames: assignees.map(&:username) } }
  let(:expected_result) do
    assignees.map { |u| { 'username' => u.username } }
  end

  let(:mutation) do
    variables = {
      project_path: project.full_path,
      iid: merge_request.iid.to_s
    }
    graphql_mutation(:merge_request_set_assignees, variables.merge(input),
                     <<-QL.strip_heredoc
                       clientMutationId
                       errors
                       mergeRequest {
                         id
                         assignees {
                           nodes {
                             username
                           }
                         }
                       }
    QL
    )
  end

  def mutation_response
    graphql_mutation_response(:merge_request_set_assignees)
  end

  def mutation_assignee_nodes
    mutation_response['mergeRequest']['assignees']['nodes']
  end

  before do
    project.add_developer(current_user)
    assignees.each do |user|
      project.add_developer(user)
    end
    extra_assignees.each do |user|
      project.add_developer(user)
    end
  end

  it 'adds the assignees to the merge request' do
    post_graphql_mutation(mutation, current_user: current_user)

    expect(response).to have_gitlab_http_status(:success)
    expect(mutation_assignee_nodes).to match_array(expected_result)
  end

  context 'with assignees already assigned' do
    before do
      merge_request.assignees = extra_assignees
      merge_request.save!
    end

    it 'removes assignees not in the list' do
      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)
      expect(mutation_assignee_nodes).to match_array(expected_result)
    end
  end

  context 'when passing append as true' do
    let(:input) { { assignee_usernames: assignees.map(&:username), operation_mode: Types::MutationOperationModeEnum.enum[:append] } }
    let(:expected_result) do
      assignees.map { |u| { 'username' => u.username } } + extra_assignees.map { |u| { 'username' => u.username } }
    end

    before do
      merge_request.assignees = extra_assignees
      merge_request.save!
    end

    it 'does not remove users not in the list' do
      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)
      expect(mutation_assignee_nodes).to match_array(expected_result)
    end
  end
end
