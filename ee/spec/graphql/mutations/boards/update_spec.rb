# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Boards::Update do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:board) { create(:board, project: project) }
  let_it_be(:milestone) { create(:milestone, project: project) }
  let(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }
  let(:mutated_board) { subject[:board] }

  specify { expect(described_class).to require_graphql_authorizations(:admin_board) }

  describe '#resolve' do
    let(:mutation_params) do
      {
        id: board.to_global_id,
        name: 'Test board 1',
        hide_backlog_list: true,
        hide_closed_list: true,
        weight: 3,
        assignee_id: user.to_global_id,
        milestone_id: milestone.to_global_id
      }
    end

    subject { mutation.resolve(mutation_params) }

    context 'when the user cannot admin the board' do
      it 'raises an error' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'with invalid params' do
      it 'raises an error' do
        mutation_params[:id] = project.to_global_id

        expect { subject }
          .to raise_error(Gitlab::Graphql::Errors::ArgumentError, "#{project.to_global_id} is not a valid ID for Board.")
      end
    end

    context 'when user can update board' do
      before do
        board.resource_parent.add_reporter(user)
      end

      it 'updates issue with correct values' do
        expected_attributes = {
          name: 'Test board 1',
          hide_backlog_list: true,
          hide_closed_list: true,
          weight: 3,
          assignee: user,
          milestone: milestone
        }

        subject

        expect(board.reload).to have_attributes(expected_attributes)
      end
    end
  end
end
