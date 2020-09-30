# frozen_string_literal: true

require 'spec_helper'

# Based on ee/spec/requests/api/epics_spec.rb
# Should follow closely in order to ensure all situations are covered
RSpec.describe 'Query.group.mergeRequests' do
  include GraphqlHelpers

  let_it_be(:group)     { create(:group) }
  let_it_be(:sub_group) { create(:group, parent: group) }

  let_it_be(:project_a) { create(:project, :repository, group: group) }
  let_it_be(:project_b) { create(:project, :repository, group: group) }
  let_it_be(:project_c) { create(:project, :repository, group: sub_group) }
  let_it_be(:project_x) { create(:project, :repository) }
  let_it_be(:user)      { create(:user, developer_projects: [project_x]) }

  let_it_be(:mr_attrs) do
    { target_branch: 'master' }
  end

  let_it_be(:mr_traits) do
    [:unique_branches, :unique_author]
  end

  let_it_be(:mrs_a) { create_list(:merge_request, 2, *mr_traits, **mr_attrs, source_project: project_a) }
  let_it_be(:mrs_b) { create_list(:merge_request, 2, *mr_traits, **mr_attrs, source_project: project_b) }
  let_it_be(:mrs_c) { create_list(:merge_request, 2, *mr_traits, **mr_attrs, source_project: project_c) }
  let_it_be(:other_mr) { create(:merge_request, source_project: project_x) }

  let(:mrs_data) { graphql_data_at(:group, :merge_requests, :nodes) }

  before do
    group.add_developer(user)
  end

  describe 'not passing any arguments' do
    let(:query) do
      <<~GQL
      query($path: ID!) {
        group(fullPath: $path) {
          mergeRequests { nodes { id } }
        }
      }
      GQL
    end

    it 'can find all merge requests in the group, excluding sub-groups' do
      post_graphql(query, current_user: user, variables: { path: group.full_path })

      expected_mrs = (mrs_a + mrs_b).map do |mr|
        a_hash_including('id' => mr.to_global_id.to_s)
      end

      expect(mrs_data).to match_array(expected_mrs)
    end
  end

  describe 'restricting by author' do
    let(:query) do
      <<~GQL
      query($path: ID!, $user: String) {
        group(fullPath: $path) {
          mergeRequests(authorUsername: $user) { nodes { id author{ username } } }
        }
      }
      GQL
    end

    let(:author) { mrs_b.first.author }

    it 'can find all merge requests with user as author' do
      post_graphql(query, current_user: user, variables: { user: author.username, path: group.full_path })

      expect(mrs_data).to contain_exactly(a_hash_including('id' => mrs_b.first.to_global_id.to_s))
    end
  end

  describe 'restricting by assignee' do
    let(:query) do
      <<~GQL
      query($path: ID!, $user: String) {
        group(fullPath: $path) {
          mergeRequests(assigneeUsername: $user) { nodes { id } }
        }
      }
      GQL
    end

    let_it_be(:assignee) { create(:user) }

    before do
      mrs_b.second.assignees << assignee
      mrs_a.first.assignees << assignee
    end

    it 'can find all merge requests assigned to user' do
      post_graphql(query, current_user: user, variables: { user: assignee.username, path: group.full_path })

      expected_mrs = [mrs_a.first, mrs_b.second].map do |mr|
        a_hash_including('id' => mr.to_global_id.to_s)
      end

      expect(mrs_data).to match_array(expected_mrs)
    end
  end

  describe 'passing include_subgroups: true' do
    let(:query) do
      <<~GQL
      query($path: ID!) {
        group(fullPath: $path) {
          mergeRequests(includeSubgroups: true) { nodes { id } }
        }
      }
      GQL
    end

    it 'can find all merge requests in the group, including sub-groups' do
      post_graphql(query, current_user: user, variables: { path: group.full_path })

      expected_mrs = (mrs_a + mrs_b + mrs_c).map do |mr|
        a_hash_including('id' => mr.to_global_id.to_s)
      end

      expect(mrs_data).to match_array(expected_mrs)
    end
  end
end
