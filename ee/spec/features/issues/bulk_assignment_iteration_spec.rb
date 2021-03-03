# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Issues > Iteration bulk assignment' do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:project_without_group) { create(:project, :public) }
  let_it_be(:issue1) { create(:issue, project: project, title: "Issue 1") }
  let_it_be(:issue2) { create(:issue, project: project, title: "Issue 2") }
  let_it_be(:issue3) { create(:issue, project: project_without_group, title: "Issue 3") }
  let_it_be(:iteration) { create(:iteration, group: group, title: "Iteration 1") }

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

  context 'as an allowed user', :js do
    before do
      group.add_maintainer(user)

      sign_in user
    end

    context 'at group level' do
      it_behaves_like 'bulk edit iteration', :group
    end

    context 'at project level' do
      it_behaves_like 'bulk edit iteration', :project
      it_behaves_like 'cannot find iterations when project does not have a group', :project_without_group
    end
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
end
