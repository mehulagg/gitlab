# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Getting issues for an epic' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:epic) { create(:epic, group: group) }
  let_it_be(:project) { create(:project, :private, group: group) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:confidential_issue) { create(:issue, :confidential, project: project) }
  let_it_be(:epic_issue) { create(:epic_issue, epic: epic, issue: issue, relative_position: 3) }
  let_it_be(:epic_issue2) { create(:epic_issue, epic: epic, issue: confidential_issue, relative_position: 5) }

  let(:epics_data) { graphql_data['group']['epics']['edges'] }

  let(:epic_node) do
    <<~NODE
      edges {
        node {
          iid
          issues {
            edges {
              node {
                id
              }
            }
          }
        }
      }
    NODE
  end

  def epic_query(params = {})
    graphql_query_for("group", { "fullPath" => group.full_path },
                       query_graphql_field("epics", params, epic_node)
    )
  end

  def issue_ids
    node_array(epics_data).each_with_object({}) do |node, result|
      result[node['iid'].to_i] = node_array(node['issues']['edges'], 'id')
    end
  end

  def first_epic_issues_page_info
    epics_data.first['node']['issues']['pageInfo']
  end

  context 'when epics are enabled' do
    before do
      stub_licensed_features(epics: true)
    end

    it 'does not return inaccessible issues' do
      post_graphql(epic_query(iid: epic.iid), current_user: user)

      expect(response).to have_gitlab_http_status(:success)
      expect(issue_ids[epic.iid]).to be_empty
    end

    context 'when user has access to the issue project' do
      before do
        project.add_developer(user)
      end

      it 'returns issues in this project' do
        post_graphql(epic_query(iid: epic.iid), current_user: user)

        expect(response).to have_gitlab_http_status(:success)
        expect(issue_ids[epic.iid]).to eq [issue.to_global_id.to_s, confidential_issue.to_global_id.to_s]
      end

      context 'pagination' do
        let(:after_cursor) { '' }
        let(:epic_node) do
          <<~NODE
            edges {
              node {
                iid
                issues(first: 1, after: "#{after_cursor}") {
                  pageInfo {
                    hasNextPage
                    hasPreviousPage
                    startCursor
                    endCursor
                  },
                  edges {
                    node {
                      id
                    }
                  }
                }
              }
            }
          NODE
        end

        context 'without a cursor' do
          it 'return first page of issues' do
            post_graphql(epic_query(iid: epic.iid), current_user: user)

            expect(response).to have_gitlab_http_status(:success)
            expect(first_epic_issues_page_info['hasNextPage']).to be_truthy
            expect(first_epic_issues_page_info['endCursor']).to eq 'MQ'
            expect(issue_ids[epic.iid]).to eq [issue.to_global_id.to_s]
          end
        end

        context 'with an after cursor' do
          let(:after_cursor) { 'MQ' }

          it 'return first page after the cursor' do
            post_graphql(epic_query(iid: epic.iid), current_user: user)

            expect(response).to have_gitlab_http_status(:success)
            expect(first_epic_issues_page_info['hasNextPage']).to be_falsey
            expect(first_epic_issues_page_info['endCursor']).to eq 'Mg'
            expect(issue_ids[epic.iid]).to eq [confidential_issue.to_global_id.to_s]
          end
        end
      end
    end

    context 'when user is guest' do
      before do
        project.add_guest(user)
      end

      it 'filters out confidential issues' do
        post_graphql(epic_query(iid: epic.iid), current_user: user)

        expect(response).to have_gitlab_http_status(:success)
        expect(issue_ids[epic.iid]).to eq [issue.to_global_id.to_s]
      end
    end

    context 'when issues from multiple epics are queried' do
      let_it_be(:epic2) { create(:epic, group: group) }
      let_it_be(:issue2) { create(:issue, project: project) }
      let_it_be(:epic_issue3) { create(:epic_issue, epic: epic2, issue: issue2, relative_position: 3) }
      let(:params) { { iids: [epic.iid, epic2.iid] } }

      before do
        project.add_developer(user)
      end

      it 'returns issues for each epic' do
        post_graphql(epic_query(params), current_user: user)

        expect(response).to have_gitlab_http_status(:success)
        result = issue_ids
        expect(result[epic.iid]).to eq [issue.to_global_id.to_s, confidential_issue.to_global_id.to_s]
        expect(result[epic2.iid]).to eq [issue2.to_global_id.to_s]
      end

      # TODO remove the pending state of this spec when
      # we have an efficient way of preloading data on GraphQL.
      # For more information check: https://gitlab.com/gitlab-org/gitlab/-/issues/207898
      xit 'avoids N+1 queries' do
        control_count = ActiveRecord::QueryRecorder.new do
          post_graphql(epic_query(iid: epic.iid), current_user: user)
        end.count

        expect do
          post_graphql(epic_query(params), current_user: user)
        end.not_to exceed_query_limit(control_count)

        expect(graphql_errors).to be_nil
      end
    end
  end

  context 'when epics are disabled' do
    before do
      stub_licensed_features(epics: false)
    end

    it 'does not find the epic' do
      post_graphql(epic_query(iid: epic.iid), current_user: user)

      expect(response).to have_gitlab_http_status(:success)
      expect(graphql_errors).to be_nil
      expect(graphql_data['group']['epic']).to be_nil
    end
  end
end
