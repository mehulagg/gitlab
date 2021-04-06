# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Mutations::Boards::EpicBoards::EpicMoveList do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:development) { create(:group_label, group: group, name: 'Development') }
  let(:epic) { create(:epic, group: group) }

  let_it_be(:board) { create(:epic_board, group: group) }
  let_it_be(:backlog) { create(:epic_list, epic_board: board, list_type: :backlog) }
  let_it_be(:labeled_list) { create(:epic_list, epic_board: board, label: development) }

  let(:mutation) { described_class.new(object: nil, context: { current_user: current_user }, field: nil) }
  let(:params) do
    {
      board_id: board.to_global_id,
      epic_id: epic.to_global_id,
      from_list_id: backlog.to_global_id,
      to_list_id: labeled_list.to_global_id
    }
  end

  subject { mutation.resolve(**params) }

  context 'arguments' do
    subject { described_class }

    it { is_expected.to have_graphql_arguments(:boardId, :epicId, :fromListId, :toListId) }
  end

  describe '#resolve' do
    context 'when epic_boards are disabled' do
      before do
        stub_licensed_features(epics: true)
        stub_feature_flags(epic_boards: false)
        group.add_developer(current_user)
      end

      it 'raises resource not available error' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when epic_boards are enabled' do
      before do
        stub_licensed_features(epics: true)
        stub_feature_flags(epic_boards: true)
      end

      context 'when user does not have permissions to admin the board' do
        it 'raises resource not available error' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when user has permissions to admin the board' do
        before do
          group.add_developer(current_user)
        end

        it 'moves the epic to another list' do
          expect { subject }.to change { epic.reload.labels }.from([]).to([development])
        end
      end
    end
  end
end
