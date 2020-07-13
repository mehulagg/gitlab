# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User views iteration' do
  let_it_be(:now) { Time.now }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user) { create(:group_member, :maintainer, user: create(:user), group: group ).user }
  let_it_be(:iteration) { create(:iteration, :skip_future_date_validation, group: group, start_date: now - 1.day, due_date: now) }
  let_it_be(:issue) { create(:issue, project: project, iteration: iteration) }
  let_it_be(:assigned_issue) { create(:issue, project: project, iteration: iteration, assignees: [user]) }
  let_it_be(:closed_issue) { create(:closed_issue, project: project, iteration: iteration) }

  context 'with license' do
    before do
      stub_licensed_features(iterations: true)
    end

    context 'view an iteration', :js do
      before do
        visit group_iteration_path(iteration.group, iteration)
      end

      it 'shows iteration info and dates' do
        expect(page).to have_content(iteration.title)
        expect(page).to have_content(iteration.description)
        expect(page).to have_content(iteration.start_date.strftime('%b %-d, %Y'))
        expect(page).to have_content(iteration.due_date.strftime('%b %-d, %Y'))
      end
    end
  end
end
