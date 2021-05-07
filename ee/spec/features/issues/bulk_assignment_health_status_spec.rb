# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Issues > Health status bulk assignment' do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:issue1) { create(:issue, project: project, title: "Issue 1") }
  let_it_be(:issue2) { create(:issue, project: project, title: "Issue 2") }

  shared_examples 'bulk edit option in sidebar' do |context|
    it 'is present when bulk edit is enabled' do
      enable_bulk_update(context)
      expect(page).to have_css('.issuable-sidebar')
    end

    it 'is not present when bulk edit is disabled' do
      expect(page).not_to have_css('.issuable-sidebar')
    end
  end

  shared_examples 'bulk edit health status' do |context|
    before do
      enable_bulk_update(context)
    end

    context 'health_status', :js do
      context 'to all issues' do
        before do
          check 'check-all-issues'
          open_health_status_dropdown ['On track']
          update_issues
        end

        it 'updates the health statuses' do
          expect(issue1.reload.health_status).to eq 'on_track'
          expect(issue2.reload.health_status).to eq 'on_track'
        end
      end

      context 'to an issue' do
        before do
          check "selected_issue_#{issue1.id}"
          open_health_status_dropdown ['At risk']
          update_issues
        end

        it 'updates the checked issue\'s status' do
          expect(issue1.reload.health_status).to eq 'at_risk'
          expect(issue2.reload.health_status).to eq nil
        end
      end
    end
  end

  shared_examples 'bulk edit health_status with insufficient permissions' do
    it 'cannot bulk assign health_status' do
      expect(page).not_to have_button 'Edit issues'
      expect(page).not_to have_css '.check-all-issues'
      expect(page).not_to have_css '.issue-check'
    end
  end

  context 'as an allowed user', :js do
    before do
      allow(group).to receive(:feature_enabled?).and_return(true)

      stub_licensed_features(group_bulk_edit: true, issuable_health_status: true)

      group.add_maintainer(user)

      sign_in user
    end

    context 'at group level' do
      it_behaves_like 'bulk edit option in sidebar', :group
      it_behaves_like 'bulk edit health status', :group
    end

    context 'at project level' do
      it_behaves_like 'bulk edit option in sidebar', :project
      it_behaves_like 'bulk edit health status', :project
    end
  end

  context 'as a guest', :js do
    before do
      sign_in user
      allow(group).to receive(:feature_enabled?).and_return(true)

      stub_licensed_features(issuable_health_status: true)
    end

    context 'at group level' do
      before do
        visit issues_group_path(group)
      end

      it_behaves_like 'bulk edit health_status with insufficient permissions'
    end

    context 'at project level' do
      before do
        visit project_issues_path(project)
      end

      it_behaves_like 'bulk edit health_status with insufficient permissions'
    end
  end

  def open_health_status_dropdown(items = [])
    page.within('.issues-bulk-update') do
      click_button 'Select health status'
      items.map do |item|
        find('[data-testid="health-status-dropdown-item"]', text: item).click
      end
    end
  end

  def toggle_issue(issue, uncheck = false)
    page.within('.issues-list') do
      if uncheck
        uncheck "selected_issue_#{issue.id}"
      else
        check "selected_issue_#{issue.id}"
      end
    end
  end

  def uncheck_issue(issue)
    toggle_issue(issue, uncheck: true)
  end

  def update_issues
    find('.update-selected-issues').click
    wait_for_requests
  end

  def enable_bulk_update(context)
    if context == :project
      visit project_issues_path(project)
    else
      visit issues_group_path(group)
    end

    click_button 'Edit issues'
  end
end
