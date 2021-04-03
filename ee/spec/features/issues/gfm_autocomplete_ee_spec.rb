# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GFM autocomplete EE', :js do
  let_it_be(:user) { create(:user, name: '💃speciąl someone💃', username: 'someone.special') }
  let_it_be(:another_user) { create(:user, name: 'another user', username: 'another.user') }
  let_it_be(:group) { create(:group) }
  let_it_be(:epic) { create(:epic, group: group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:issue) { create(:issue, project: project, assignees: [user]) }

  before do
    project.add_maintainer(user)
  end

  context 'assignees' do
    describe 'when tribute_autocomplete feature flag is off' do
      before do
        stub_feature_flags(tribute_autocomplete: false)

        sign_in(user)

        visit project_issue_path(project, issue)
      end

      it 'only lists users who are currently assigned to the issue when using /unassign' do
        fill_in 'Comment', with: '/una'

        find_highlighted_autocomplete_item.click

        wait_for_requests

        expect(find_autocomplete_menu).to have_text(user.username)
        expect(find_autocomplete_menu).not_to have_text(another_user.username)
      end
    end

    describe 'when tribute_autocomplete feature flag is on' do
      before do
        stub_licensed_features(epics: true)
        stub_feature_flags(tribute_autocomplete: true)

        sign_in(user)

        visit project_issue_path(project, issue)
      end

      it 'only lists users who are currently assigned to the issue when using /unassign' do
        note = find_field('Comment')
        note.native.send_keys('/unassign ')
        # The `/unassign` ajax response might replace the one by `@` below causing a failed test
        # so we need to wait for the `/assign` ajax request to finish first
        wait_for_requests
        note.native.send_keys('@')
        wait_for_requests

        expect(find_tribute_autocomplete_menu).to have_text(user.username)
        expect(find_tribute_autocomplete_menu).not_to have_text(another_user.username)
      end

      it 'shows epics' do
        fill_in 'Comment', with: '&'

        wait_for_requests

        expect(find_tribute_autocomplete_menu).to have_text(epic.title)
      end
    end
  end

  private

  def find_autocomplete_menu
    find('.atwho-view ul', visible: true)
  end

  def find_highlighted_autocomplete_item
    find('.atwho-view li.cur', visible: true)
  end

  def find_tribute_autocomplete_menu
    find('.tribute-container ul', visible: true)
  end
end
