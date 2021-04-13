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

  let(:current_ctx) { { current_user: current_user } }
  let(:params) do
    {
      board_id: board.to_global_id,
      epic_id: epic.to_global_id
    }
  end

  let(:move_params) do
    {
      from_list_id: backlog.to_global_id,
      to_list_id: labeled_list.to_global_id
    }
  end

  subject do
    sync(resolve(described_class, args: params.merge(move_params), ctx: current_ctx))
  end

  context 'arguments' do
    subject { described_class }

    it { is_expected.to have_graphql_arguments(:boardId, :epicId, :fromListId, :toListId, :moveBeforeId, :moveAfterId) }
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

        context 'when required move params are missing' do
          let(:move_params) { { to_list_id: backlog.to_global_id } }

          it 'raises an error' do
            expect { subject }.to raise_error(
              Gitlab::Graphql::Errors::ArgumentError,
              'One of the params fromListId, afterId, beforeId is required together with toListId param'
            )
          end
        end

        context 'moving an epic to another list' do
          it 'moves the epic to another list' do
            expect { subject }.to change { epic.reload.labels }.from([]).to([development])
          end
        end

        context 'repositioning an epic' do
          let!(:epic1) { create(:epic, group: group) }
          let!(:epic_board_position) { create(:epic_board_position, epic_board: board, epic: epic1) }
          let!(:epic2) { create(:epic, group: group) }
          let!(:epic3) { create(:epic, group: group) }

          def position(epic)
            epic.epic_board_positions.first.relative_position
          end

          context 'when both move_before_id and move_after_id params are present' do
            let(:move_params) do
              {
                move_before_id: epic3.to_global_id,
                move_after_id: epic2.to_global_id,
                to_list_id: backlog.to_global_id
              }
            end

            it 'repositions the epic' do
              subject

              expect(position(epic)).to be > position(epic3)
            end
          end

          context 'when only move_before_id param is present' do
            let(:move_params) do
              {
                to_list_id: backlog.to_global_id,
                move_before_id: epic3.to_global_id
              }
            end

            it 'repositions the epic' do
              subject

              expect(position(epic)).to be > position(epic3)
            end
          end

          context 'when only move_after_id param is present' do
            let(:move_params) do
              {
                to_list_id: backlog.to_global_id,
                move_after_id: epic3.to_global_id
              }
            end

            it 'repositions the epic' do
              subject

              expect(position(epic)).to be < position(epic3)
            end
          end
        end
      end
    end
  end
end
