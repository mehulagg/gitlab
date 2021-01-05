# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Issues > Iteration bulk assignment' do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:issue1) { create(:issue, project: project, title: "Issue 1") }
  let_it_be(:issue2) { create(:issue, project: project, title: "Issue 2") }
  let_it_be(:iteration) { create(:iteration, group: group, title: "Iteration 1") }

  shared_examples 'bulk edit iteration' do |context|
    before do
      enable_bulk_update(context)
    end

    context 'iteration', :js do
      context 'to all issues' do
        before do
          check 'check-all-issues'
          open_iteration_dropdown ['Iteration 1']
          update_issues
        end

        it 'updates the iteration' do
          expect(issue1.reload.iteration.name).to eq 'Iteration 1'
        end
      end
    end
  end

  context 'as an allowed user', :js do
    before do
      # allow(group).to receive(:feature_enabled?).and_return(true)

      # stub_licensed_features(iterations: true)
      group.add_maintainer(user)

      sign_in user
    end

    context 'at group level' do
      it_behaves_like 'bulk edit iteration', :group
    end

    context 'at project level' do
      it_behaves_like 'bulk edit iteration', :project
    end
  end

  def enable_bulk_update(context)
    if context == :project
      visit project_issues_path(project)
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
