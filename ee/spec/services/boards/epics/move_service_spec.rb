# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::Epics::MoveService do
  describe '#execute' do
    let_it_be(:user) { create(:user) }
    let_it_be(:group) { create(:group) }
    let_it_be(:board) { create(:epic_board, group: group) }

    let_it_be(:development) { create(:group_label, group: group, name: 'Development') }
    let_it_be(:testing) { create(:group_label, group: group, name: 'Testing') }

    let_it_be(:backlog) { create(:epic_list, epic_board: board, list_type: :backlog, label: nil) }
    let_it_be(:list1) { create(:epic_list, epic_board: board, label: development, position: 0) }
    let_it_be(:list2) { create(:epic_list, epic_board: board, label: testing, position: 1) }
    let_it_be(:closed) { create(:epic_list, epic_board: board, list_type: :closed, label: nil) }

    let(:epic) { create(:epic, group: group) }

    before do
      stub_licensed_features(epics: true)
    end

    subject { described_class.new(group, user, params).execute(epic) }

    context 'when user does not have permissions to move an epic' do
      let(:params) { { board_id: board.id, from_list_id: backlog.id, to_list_id: closed.id } }

      it 'does not close the epic' do
        expect { subject }.not_to change { epic.state }
      end
    end

    context 'when user has permissions to move an epic' do
      before do
        group.add_maintainer(user)
      end

      context 'when moving the epic from backlog' do
        context 'to a labeled list' do
          let(:params) { { board_id: board.id, from_list_id: backlog.id, to_list_id: list1.id } }

          it 'keeps the epic opened and adds the labels' do
            expect { subject }.not_to change { epic.state }

            expect(epic.labels).to eq([development])
          end
        end

        context 'to the closed list' do
          let(:params) { { board_id: board.id, from_list_id: backlog.id, to_list_id: closed.id } }

          it 'closes the epic' do
            expect { subject }.to change { epic.state }.from('opened').to('closed')
          end
        end
      end

      context 'when moving the epic from a labeled list' do
        before do
          epic.labels = [development]
        end

        context 'to another labeled list' do
          let(:params) { { board_id: board.id, from_list_id: list1.id, to_list_id: list2.id } }

          it 'changes the labels' do
            expect { subject }.to change { epic.reload.labels }.from([development]).to([testing])
          end
        end

        context 'to the closed list' do
          let(:params) { { board_id: board.id, from_list_id: list1.id, to_list_id: closed.id } }

          it 'closes the epic' do
            expect { subject }.to change { epic.state }.from('opened').to('closed')
          end
        end
      end
    end
  end
end
