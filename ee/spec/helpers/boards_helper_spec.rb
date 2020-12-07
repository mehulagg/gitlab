# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BoardsHelper do
  let_it_be(:project) { create(:project) }
  let_it_be(:group) { create(:group) }

  describe '#board_list_data' do
    let(:results) { helper.board_list_data }

    it 'contains an endpoint to get users list' do
      board = create(:board, project: project)
      assign(:board, board)
      assign(:project, project)

      expect(results).to include(list_assignees_path: "/-/boards/#{board.id}/users.json")
    end
  end

  describe '#current_board_json' do
    let(:board_json) { helper.current_board_json }
    let(:user) { create(:user) }
    let(:label1) { create(:label, name: "feijoa") }
    let(:label2) { create(:label, name: "pineapple") }
    let(:milestone) { create(:milestone) }

    it 'serializes with child object attributes' do
      board = create(:board, project: project, milestone: milestone, assignee: user, labels: [label1, label2])
      assign(:board, board)

      expect(board_json).to match_schema('current-board', dir: 'ee')
    end
  end

  describe '#board_data' do
    let_it_be(:user) { create(:user) }
    let_it_be(:board) { create(:board, project: project) }
    let(:board_data) { helper.board_data }

    before do
      assign(:board, board)
      assign(:project, project)

      allow(helper).to receive(:current_user) { user }
      allow(helper).to receive(:can?).with(user, :create_non_backlog_issues, board).and_return(true)
      allow(helper).to receive(:can?).with(user, :admin_issue, board).and_return(true)
    end

    context 'when no iteration', :aggregate_failures do
      it 'serializes board without iteration' do
        expect(board_data[:board_iteration_title]).to be_nil
        expect(board_data[:board_iteration_id]).to be_nil
      end
    end

    context 'when board is scoped to an iteration' do
      let_it_be(:iteration) { create(:iteration, group: group) }

      before do
        board.update!(iteration: iteration)
      end

      it 'serializes board with iteration' do
        expect(board_data[:board_iteration_title]).to eq(iteration.title)
        expect(board_data[:board_iteration_id]).to eq(iteration.id)
      end
    end
  end
end
