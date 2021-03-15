# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Boards::EpicBoards::Destroy do
  include GraphqlHelpers

  let_it_be_with_reload(:current_user) { create(:user) }
  let_it_be_with_reload(:group) { create(:group) }
  let_it_be(:board) { create(:epic_board, group: group) }
  let_it_be(:other_board) { create(:epic_board, group: group) }

  let(:mutation) do
    variables = {
      id: board.to_global_id.to_s
    }

    graphql_mutation(:destroy_epic_board, variables)
  end

  subject { post_graphql_mutation(mutation, current_user: current_user) }

  def mutation_response
    graphql_mutation_response(:destroy_epic_board)
  end

  context 'when the user does not have permission' do
    it_behaves_like 'a mutation that returns a top-level access error'

    it 'does not destroy the board' do
      expect { subject }.not_to change { Board.count }
    end
  end

  context 'when the user has permission' do
    before do
      project.add_maintainer(current_user)
    end

    context 'when given id is not for a board' do
      let_it_be(:board) { build_stubbed(:issue, project: project) }

      it 'returns an error' do
        subject

        expect(graphql_errors.first['message']).to include('does not represent an instance of Board')
      end
    end

    context 'when everything is ok' do
      it 'destroys the board' do
        expect { subject }.to change { Board.count }.from(2).to(1)
      end

      it 'returns an empty board' do
        post_graphql_mutation(mutation, current_user: current_user)

        expect(mutation_response).to have_key('board')
        expect(mutation_response['board']).to be_nil
      end
    end

    context 'when there is only 1 board for the parent' do
      before do
        other_board.destroy!
      end

      it 'does not destroy the board' do
        expect { subject }.not_to change { Board.count }.from(1)
      end

      it 'returns an error and not nil board' do
        subject

        expect(mutation_response['errors']).not_to be_empty
        expect(mutation_response['board']).not_to be_nil
      end
    end
  end
end
