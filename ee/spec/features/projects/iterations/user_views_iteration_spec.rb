# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User views iteration' do
  let_it_be(:now) { Time.now }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:project_2) { create(:project, group: group) }
  let_it_be(:user) { create(:group_member, :maintainer, user: create(:user), group: group).user }
  let_it_be(:iteration) { create(:iteration, :skip_future_date_validation, iid: 1, id: 2, group: group, title: 'Correct Iteration', start_date: now - 1.day, due_date: now) }
  let_it_be(:other_iteration) { create(:iteration, :skip_future_date_validation, iid: 2, id: 1, group: group, title: 'Wrong Iteration', start_date: now - 4.days, due_date: now - 3.days) }
  let_it_be(:issue) { create(:issue, project: project, iteration: iteration) }
  let_it_be(:assigned_issue) { create(:issue, project: project_2, iteration: iteration, assignees: [user]) }
  let_it_be(:closed_issue) { create(:closed_issue, project: project, iteration: iteration) }
  let_it_be(:other_issue) { create(:issue, project: project, iteration: other_iteration) }

  context 'with license' do
    before do
      stub_licensed_features(iterations: true)
      sign_in(user)
    end

    context 'view an iteration', :js do
      before do
        visit project_iterations_inherited_path(project, iteration.id)
      end

      it 'shows iteration info and dates' do
        expect(page).to have_content(iteration.title)
        expect(page).to have_content(iteration.description)
        expect(page).to have_content(iteration.start_date.strftime('%b %-d, %Y'))
        expect(page).to have_content(iteration.due_date.strftime('%b %-d, %Y'))
      end

      it 'shows correct summary information' do
        expect(page).to have_content("Complete 50%")
        expect(page).to have_content("Open 1")
        expect(page).to have_content("In progress 0")
        expect(page).to have_content("Completed 1")
      end

      it 'shows only issues that are part of the project' do
        expect(page).to have_content(issue.title)
        expect(page).not_to have_content(assigned_issue.title)
        expect(page).to have_content(closed_issue.title)
        expect(page).not_to have_content(other_issue.title)
      end

      it 'hides action dropdown for editing the iteration' do
        expect(page).not_to have_button('Actions')
      end
    end
  end

  context 'without license' do
    before do
      stub_licensed_features(iterations: false)
      sign_in(user)
    end

    it 'shows page not found' do
      visit project_iterations_inherited_path(project, iteration.id)

      expect(page).to have_title('Not Found')
      expect(page).to have_content('Page Not Found')
    end
  end
end
