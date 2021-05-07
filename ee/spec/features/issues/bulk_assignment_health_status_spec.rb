# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Issues > Bulk edit issues' do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:epic) { create(:epic, group: group) }
  let_it_be(:iteration) { create(:iteration, group: group, title: "Iteration 1") }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:project_without_group) { create(:project, :public) }

  let!(:issue1) { create(:issue, project: project, title: "Issue 1") }
  let!(:issue2) { create(:issue, project: project, title: "Issue 2") }
  let!(:issue3) { create(:issue, project: project_without_group, title: "Issue 3") }

  shared_examples 'bulk edit option in sidebar' do |context|
    it 'is present when bulk edit is enabled' do
      enable_bulk_update(context)
      expect(page).to have_css('.issuable-sidebar')
    end

    it 'is not present when bulk edit is disabled' do
      expect(page).not_to have_css('.issuable-sidebar')
    end
  end

  shared_examples 'bulk edit epic' do |context|
    before do
      enable_bulk_update(context)
    end

    context 'epic', :js do
      context 'to all issues' do
        before do
          check 'check-all-issues'
          open_epic_dropdown [epic.title]
          update_issues
        end

        it 'updates with selected epic' do
          expect(issue1.reload.epic.title).to eq epic.title
          expect(issue2.reload.epic.title).to eq epic.title
        end
      end

      context 'to a issue' do
        before do
          check "selected_issue_#{issue1.id}"
          open_epic_dropdown [epic.title]
          update_issues
        end

        it 'updates with selected epic' do
          expect(issue1.reload.epic.title).to eq epic.title
          expect(issue2.reload.epic).to eq nil
        end
      end
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

  shared_examples 'bulk edit iteration' do |context|
    context 'iteration', :js do
      before do
        enable_bulk_update(context)
      end
      context 'to all issues' do
        before do
          check 'check-all-issues'
          open_iteration_dropdown ['Iteration 1']
          update_issues
        end

        it 'updates the iteration' do
          aggregate_failures 'each issue in list' do
            expect(issue1.reload.iteration.name).to eq 'Iteration 1'
            expect(issue2.reload.iteration.name).to eq 'Iteration 1'
          end
        end
      end
    end

    context 'cannot find iteration when iterations is off', :js do
      before do
        stub_licensed_features(iterations: false)

        enable_bulk_update(context)
      end

      it 'cannot find iteration dropdown' do
        expect(page).not_to have_selector('[data-qa-selector="iteration_container"]')
      end
    end
  end

  shared_examples 'cannot find iterations when project does not have a group' do |context|
    context 'cannot find iteration when group does not belong to project', :js do
      before do
        project_without_group.add_maintainer(user)

        enable_bulk_update(context)
      end

      it 'cannot find iteration dropdown' do
        expect(page).not_to have_selector('[data-qa-selector="iteration_container"]')
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

      stub_licensed_features(epics: true, group_bulk_edit: true, issuable_health_status: true, iterations: true)

      group.add_maintainer(user)

      sign_in user
    end

    context 'at group level' do
      it_behaves_like 'bulk edit option in sidebar', :group
      it_behaves_like 'bulk edit epic', :group
      it_behaves_like 'bulk edit health status', :group
      it_behaves_like 'bulk edit iteration', :group
    end

    context 'at project level' do
      it_behaves_like 'bulk edit option in sidebar', :project
      it_behaves_like 'bulk edit epic', :project
      it_behaves_like 'bulk edit health status', :project
      it_behaves_like 'bulk edit iteration', :project
      it_behaves_like 'cannot find iterations when project does not have a group', :project_without_group
    end
  end

  context 'as a guest', :js do
    before do
      allow(group).to receive(:feature_enabled?).and_return(true)

      stub_licensed_features(epics: true, group_bulk_edit: true, issuable_health_status: true, iterations: true)

      sign_in user
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

  def open_epic_dropdown(items = [])
    page.within('.issues-bulk-update') do
      click_button 'Select epic'
      items.map do |item|
        find('.gl-new-dropdown-item', text: item).click
      end
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

  def open_iteration_dropdown(items = [])
    page.within('.issues-bulk-update') do
      click_button 'Select iteration'
      items.map do |item|
        find('.dropdown-item', text: item).click
      end
    end
  end

  def update_issues
    find('.update-selected-issues').click
    wait_for_requests
  end

  def enable_bulk_update(context)
    if context == :project
      visit project_issues_path(project)
    elsif context == :project_without_group
      visit project_issues_path(project_without_group)
    else
      visit issues_group_path(group)
    end

    click_button 'Edit issues'
  end
end
