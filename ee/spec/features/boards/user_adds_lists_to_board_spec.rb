# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User adds milestone lists', :js do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:group) { create(:group, :nested) }
  let_it_be(:project) { create(:project, :public, namespace: group) }
  let_it_be(:group_board) { create(:board, group: group) }
  let_it_be(:project_board) { create(:board, project: project) }
  let_it_be(:user) { create(:user) }

  let_it_be(:milestone) { create(:milestone, group: group) }

  let_it_be(:group_backlog_list) { create(:backlog_list, board: group_board) }

  let_it_be(:issue_with_milestone) { create(:issue, project: project, milestone: milestone) }
  let_it_be(:issue_with_assignee) { create(:issue, project: project, assignees: [user]) }

  before_all do
    project.add_maintainer(user)
    group.add_owner(user)
  end

  where(:board_type, :graphql_board_lists_enabled) do
    :project | true
    :project | false
    :group   | true
    :group   | false
  end

  with_them do
    before do
      stub_licensed_features(
        board_milestone_lists: true,
        board_assignee_lists: true
      )
      sign_in(user)

      set_cookie('sidebar_collapsed', 'true')

      stub_feature_flags(
        graphql_board_lists: graphql_board_lists_enabled,
        board_new_list: true
      )

      if board_type == :project
        visit project_board_path(project, project_board)
      elsif board_type == :group
        visit group_board_path(group, group_board)
      end

      wait_for_all_requests
    end

    it 'creates milestone column' do
      add_list('Milestone', milestone.title)

      expect(page).to have_selector('.board', text: milestone.title)
      expect(find('.board:nth-child(2) .board-card')).to have_content(issue_with_milestone.title)
    end

    it 'creates assignee column' do
      add_list('Assignee', user.name)

      expect(page).to have_selector('.board', text: user.name)
      expect(find('.board:nth-child(2) .board-card')).to have_content(issue_with_assignee.title)
    end
  end

  def add_list(list_type, title)
    click_button 'Create list'
    wait_for_all_requests

    select(list_type, from: 'List type')

    page.within('.board-add-new-list') do
      find('label', text: title).click
      click_button 'Add'
    end

    wait_for_all_requests
  end
end
