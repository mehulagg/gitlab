# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GFM autocomplete EE', :js do
  let_it_be(:user) { create(:user, name: '💃speciąl someone💃', username: 'someone.special') }
  let_it_be(:another_user) { create(:user, name: 'another user', username: 'another.user') }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:epic) { create(:epic, group: group) }
  let_it_be(:iteration) { create(:iteration, group: group, start_date: Time.now, due_date: Time.now + 1.day) }

  before do
    project.add_maintainer(user)
  end

  context 'assignees' do
    let(:issue_assignee) { create(:issue, project: project) }

    describe 'when tribute_autocomplete feature flag is off' do
      before do
        stub_feature_flags(tribute_autocomplete: false)

        issue_assignee.update!(assignees: [user])

        sign_in(user)
        visit project_issue_path(project, issue_assignee)

        wait_for_requests
      end

      it 'only lists users who are currently assigned to the issue when using /unassign' do
        note = find('#note-body')
        page.within '.timeline-content-form' do
          note.native.send_keys('/una')
        end

        find('.atwho-view li', text: '/unassign')
        note.native.send_keys(:tab)

        wait_for_requests

        users = find('#at-view-users .atwho-view-ul')
        expect(users).to have_content(user.username)
        expect(users).not_to have_content(another_user.username)
      end
    end

    describe 'when tribute_autocomplete feature flag is on' do
      before do
        stub_licensed_features(epics: true)
        stub_feature_flags(tribute_autocomplete: true)

        issue_assignee.update!(assignees: [user])

        sign_in(user)
        visit project_issue_path(project, issue_assignee)

        wait_for_requests
      end

      it 'only lists users who are currently assigned to the issue when using /unassign' do
        note = find('#note-body')
        page.within '.timeline-content-form' do
          note.native.send_keys('/una')
        end

        find('.atwho-view li', text: '/unassign')
        note.native.send_keys(:tab)
        note.native.send_keys(:right)

        wait_for_requests

        users = find('.tribute-container ul')
        expect(users).to have_content(user.username)
        expect(users).not_to have_content(another_user.username)
      end

      it 'shows epics' do
        note = find('#note-body')
        page.within('.timeline-content-form') do
          note.native.send_keys('&')
        end

        wait_for_requests

        expect(find('.tribute-container ul', visible: true).text).to have_content(epic.title)
      end

      it 'shows iterations' do
        note = find('#note-body')
        page.within('.timeline-content-form') do
          note.native.send_keys('*iteration:')
        end

        wait_for_all_requests

        expect(find('.tribute-container ul', visible: true).text).to have_content(iteration.title)
      end
    end
  end
end
