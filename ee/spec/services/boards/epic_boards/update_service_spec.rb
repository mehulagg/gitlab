# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoards::UpdateService, services: true do
  let_it_be(:parent_group) { create(:group) }
  let_it_be_with_reload(:group) { create(:group, parent: parent_group) }
  let_it_be_with_reload(:board) { create(:epic_board, group: group) }
  let_it_be(:user) { create(:user) }

  let(:parent_label) { create(:group_label, group: parent_group) }
  let(:other_label) { create(:group_label) }
  let(:label) { create(:group_label, group: group) }

  let(:epic_boards_enabled) { false }

  let(:all_params) do
    { label_ids: [label.id, other_label.id, parent_label.id],
      hide_backlog_list: true, hide_closed_list: true }
  end

  let(:updated_scoped_params) do
    { labels: [label, parent_label],
      hide_backlog_list: true, hide_closed_list: true }
  end

  let(:updated_without_scoped_params) do
    { labels: [], hide_backlog_list: true, hide_closed_list: true }
  end

  it_behaves_like 'board update service'

  it 'tracks epic board name updates' do
    expect(Gitlab::UsageDataCounters::HLLRedisCounter)
      .to receive(:track_event).with('g_project_management_users_updating_epic_board_names', values: user.id)

    described_class.new(group, user, name: 'foo').execute(board)
  end
end
