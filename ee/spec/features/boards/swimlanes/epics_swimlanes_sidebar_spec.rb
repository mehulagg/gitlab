# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'epics swimlanes sidebar', :js do
  let_it_be(:user)  { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:project, reload: true) { create(:project, :public, group: group) }

  let_it_be(:board) { create(:board, project: project) }
  let_it_be(:label) { create(:label, project: project, name: 'Label 1') }
  let_it_be(:list)  { create(:list, board: board, label: label, position: 0) }
  let_it_be(:epic1) { create(:epic, group: group) }
  let_it_be(:epic2) { create(:epic, group: group) }

  let_it_be(:issue, reload: true)      { create(:issue, project: project) }
  let_it_be(:epic_issue, reload: true) { create(:epic_issue, epic: epic1, issue: issue) }

  let(:boards_path) { project_boards_path(project, group_by: 'epic') }

  before do
    project.add_maintainer(user)

    stub_licensed_features(epics: true, swimlanes: true)

    sign_in(user)

    load_epic_swimlanes

    first_card.click
  end

  it_behaves_like 'issue boards sidebar'

  context 'epic dropdown' do
    before_all do
      group.add_owner(user)
    end

    context 'when the issue is associated with an epic' do
      it 'displays name of epic and links to it' do
        page.within('[data-testid="sidebar-epic"]') do
          expect(page).to have_link(epic1.title, href: epic_path(epic1))
        end
      end

      it 'updates the epic associated with the issue' do
        page.within('[data-testid="sidebar-epic"]') do
          find("[data-testid='edit-button']").click

          wait_for_requests

          find('.gl-new-dropdown-item', text: epic2.title).click

          wait_for_requests

          expect(page).to have_link(epic2.title, href: epic_path(epic2))
        end
      end
    end
  end

  def load_epic_swimlanes
    visit project_boards_path(project)

    wait_for_requests

    page.within('.board-swimlanes-toggle-wrapper') do
      page.find('.dropdown-toggle').click
      page.find('.dropdown-item', text: 'Epic').click
    end

    wait_for_requests
  end

  def first_card
    find("[data-testid='board-epic-lane-issues']").first("[data-testid='board_card']")
  end
end
