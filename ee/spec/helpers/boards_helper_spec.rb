# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BoardsHelper do
  let(:project) { create(:project) }

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
end
