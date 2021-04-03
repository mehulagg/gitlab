# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Issues > Epic bulk assignment', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:issue1) { create(:issue, project: project, title: "Issue 1") }
  let_it_be(:issue2) { create(:issue, project: project, title: "Issue 2") }
  let!(:epic1) { create(:epic, group: group) }

  context 'as an allowed user', :js do
    before do
      allow(group).to receive(:feature_enabled?).and_return(true)
      stub_licensed_features(epics: true)

      group.add_maintainer(user)

      sign_in user
    end

    context 'sidebar' do
      before do
        enable_bulk_update
      end

      it 'is present when bulk edit is enabled' do
        expect(page).to have_css('.issuable-sidebar')
      end

      it 'is not present when bulk edit is disabled' do
        disable_bulk_update
        expect(page).not_to have_css('.issuable-sidebar')
      end
    end

    context 'can bulk assign' do
      before do
        enable_bulk_update
      end

      context 'epic' do
        context 'to all issues' do
          before do
            check 'check-all-issues'
            open_epic_dropdown [epic1.title]
            update_issues
          end

          it do
            expect(issue1.reload.epic.title).to eq epic1.title
            expect(issue2.reload.epic.title).to eq epic1.title
          end
        end

        context 'to a issue' do
          before do
            check "selected_issue_#{issue1.id}"
            open_epic_dropdown [epic1.title]
            update_issues
          end

          it do
            expect(issue1.reload.epic.title).to eq epic1.title
            expect(issue2.reload.epic).to eq nil
          end
        end
      end
    end
  end

  context 'as a guest' do
    before do
      sign_in user
      allow(group).to receive(:feature_enabled?).and_return(true)

      stub_licensed_features(epics: true)

      visit project_issues_path(project)
    end

    context 'cannot bulk assign epic' do
      it do
        expect(page).not_to have_button 'Edit issues'
        expect(page).not_to have_css '.check-all-issues'
        expect(page).not_to have_css '.issue-check'
      end
    end
  end

  def open_epic_dropdown(items = [])
    page.within('.issues-bulk-update') do
      click_button 'Select epic'
      items.map do |item|
        find('.gl-new-dropdown-item', text: item).click
      end
    end
  end

  def check_issue(issue, uncheck = false)
    page.within('.issues-list') do
      if uncheck
        uncheck "selected_issue_#{issue.id}"
      else
        check "selected_issue_#{issue.id}"
      end
    end
  end

  def uncheck_issue(issue)
    check_issue(issue, true)
  end

  def update_issues
    find('.update-selected-issues').click
    wait_for_requests
  end

  def enable_bulk_update
    visit project_issues_path(project)
    click_button 'Edit issues'
  end

  def disable_bulk_update
    click_button 'Cancel'
  end
end
