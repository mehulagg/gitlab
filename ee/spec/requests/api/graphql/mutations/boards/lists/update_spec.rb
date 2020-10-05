# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Update an existing board list with EE attributes' do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:board) { create(:board, group: group) }
  let_it_be(:list) { create(:list, board: board, position: 0) }

  let(:current_user) { user }
  let(:mutation) { graphql_mutation(:update_board_list, input) }
  let(:mutation_response) { graphql_mutation_response(:update_board_list) }
  let(:input) { { list_id: list.to_global_id.to_s, collapsed: true, max_issue_count: 10, max_issue_weight: 55 } }

  context 'the user is not allowed to update board lists' do
    it_behaves_like 'a mutation that returns a top-level access error'
  end

  context 'when user has permissions to update board lists' do
    before do
      group.add_reporter(current_user)
    end

    describe 'max limits' do
      it 'creates the list' do
        post_graphql_mutation(mutation, current_user: current_user)

        expect(response).to have_gitlab_http_status(:success)
        expect(mutation_response['list']).to include('maxIssueCount' => 10, 'maxIssueWeight' => 55)
      end
    end
  end

  context 'when user has permissions to read board lists' do
    before do
      group.add_guest(current_user)
    end

    it 'does not set max limits' do
      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)
      expect(mutation_response['list']).to include('maxIssueCount' => 0, 'maxIssueWeight' => 0)
    end
  end
end
