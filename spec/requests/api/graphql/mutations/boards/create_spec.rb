# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Boards::Create do
  include GraphqlHelpers

  let_it_be(:current_user, reload: true) { create(:user) }
  let_it_be(:group, reload: true) { create(:group) }

  let(:name) { 'board name' }
  let(:group_path) { group.full_path }
  let(:params) do
    {
      group_path: group_path,
      name: name
    }
  end

  let(:mutation) { graphql_mutation(:create_board, params) }

  subject { post_graphql_mutation(mutation, current_user: current_user) }

  def mutation_response
    graphql_mutation_response(:create_board)
  end

  context 'when group_path param is given' do
    context 'when the user does not have permission' do
      it_behaves_like 'a mutation that returns a top-level access error'

      it 'does not create the board' do
        expect { subject }.not_to change { Board.count }
      end
    end

    context 'when the user has permission' do
      before do
        group.add_maintainer(current_user)
      end

      context 'when everything is ok' do
        it 'creates the board' do
          expect { subject }.to change { Board.count }.from(0).to(1)
        end

        it 'returns the created board' do
          post_graphql_mutation(mutation, current_user: current_user)

          expect(mutation_response).to have_key('board')
          expect(mutation_response['board']['name']).to eq(name)
        end
      end

      context 'when no additional boardd can be created' do
        before do
          create(:board, group: group)
        end

        it 'does not create a boardd' do
          expect { subject }.not_to change { Board.count }.from(1)
        end

        it 'returns an error' do
          post_graphql_mutation(mutation, current_user: current_user)

          expect(mutation_response).to have_key('board')
          expect(mutation_response['board']).to be_nil
          expect(mutation_response['errors'].first).to eq("You don't have the permission to create a board for this resource.")
        end
      end
    end
  end
end
