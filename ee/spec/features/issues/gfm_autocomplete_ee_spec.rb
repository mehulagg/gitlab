# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GFM autocomplete EE', :js do
  let_it_be(:user) { create(:user, name: '💃speciąl someone💃', username: 'someone.special') }
  let_it_be(:another_user) { create(:user, name: 'another user', username: 'another.user') }
  let_it_be(:project) { create(:project) }
  let_it_be(:issue) { create(:issue, project: project) }

  let_it_be(:group) { create(:group) }

  before_all do
    project.add_maintainer(user)
    project.add_developer(another_user)

    group.add_developer(user)
  end

  context 'assignees' do
    let(:issue_assignee) { create(:issue, project: project, assignees: [user]) }

    describe 'when tribute_autocomplete feature flag is off' do
      before do
        stub_feature_flags(tribute_autocomplete: false)

        sign_in(user)
        visit project_issue_path(project, issue_assignee)

        wait_for_requests
      end

      it 'lists users who are currently not assigned to the issue when using /reassign' do
        note = find('#note-body')
        page.within '.timeline-content-form' do
          note.native.send_keys('/reas')
        end

        find('.atwho-view li', text: '/reassign')
        note.native.send_keys(:tab)

        wait_for_requests

        expect(find('#at-view-users .atwho-view-ul')).not_to have_content(user.username)
        expect(find('#at-view-users .atwho-view-ul')).not_to have_content(group.name)
        expect(find('#at-view-users .atwho-view-ul')).to have_content(another_user.username)
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
        stub_feature_flags(tribute_autocomplete: true)

        sign_in(user)
        visit project_issue_path(project, issue_assignee)

        wait_for_requests
      end

      it 'lists users who are currently not assigned to the issue when using /reassign' do
        note = find('#note-body')
        page.within '.timeline-content-form' do
          note.native.send_keys('/reas')
        end

        find('.atwho-view li', text: '/reassign')
        note.native.send_keys(:tab)
        note.native.send_keys(:right)

        wait_for_requests

        expect(find('.tribute-container ul', visible: true)).not_to have_content(user.username)
        expect(find('.tribute-container ul', visible: true)).not_to have_content(group.name)
        expect(find('.tribute-container ul', visible: true)).to have_content(another_user.username)
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
    end
  end
end
