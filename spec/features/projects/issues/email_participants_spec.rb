# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'viewing an issue', :js do
  let_it_be(:support_bot) { User.support_bot }
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :public) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:note) { create(:note_on_issue, project: project, noteable: issue) }

  before do
    sign_in(user)
    visit project_issue_path(project, issue)
    wait_for_all_requests
  end

  context 'without `issue_email_participants`' do
    it 'does not show warning on new note form' do
      expect(find('.new-note')).not_to have_content('will be notified of your comment')
    end

    it 'does not show warning on reply form' do
      find('.js-reply-button').click

      expect(find('.note-edit-form')).not_to have_content('will be notified of your comment')
    end
  end

  context 'with `issue_email_participants`' do
    before_all do
      issue.issue_email_participants.create!(email: 'a@gitlab.com')
    end

    it 'shows warning on new note form' do
      expect(find('.new-note')).to have_content('a@gitlab.com will be notified of your comment')
    end

    it 'shows warning on reply form' do
      find('.js-reply-button').click

      expect(find('.note-edit-form')).to have_content('a@gitlab.com will be notified of your comment')
    end
  end

  context 'with more `issue_email_participants`' do
    before_all do
      issue.issue_email_participants.create!(email: 'a@gitlab.com')
      issue.issue_email_participants.create!(email: 'b@gitlab.com')
      issue.issue_email_participants.create!(email: 'c@gitlab.com')
      issue.issue_email_participants.create!(email: 'd@gitlab.com')
      issue.issue_email_participants.create!(email: 'e@gitlab.com')
    end

    it 'shows warning on new note form' do
      expect(find('.new-note')).to have_content('a@gitlab.com, b@gitlab.com, c@gitlab.com, and 2 more will be notified of your comment')
    end

    it 'shows warning on reply form' do
      find('.js-reply-button').click

      expect(find('.note-edit-form')).to have_content('a@gitlab.com, b@gitlab.com, c@gitlab.com, and 2 more will be notified of your comment')
    end

    context 'after clicking more' do
      it 'shows warning on new note form' do
        find('.issuable-note-warning button').click

        expect(find('.new-note')).to have_content('a@gitlab.com, b@gitlab.com, c@gitlab.com, d@gitlab.com, and e@gitlab.com will be notified of your comment')
      end

      it 'shows warning on reply form' do
        find('.js-reply-button').click
        find('.note-edit-form .issuable-note-warning button').click

        expect(find('.note-edit-form')).to have_content('a@gitlab.com, b@gitlab.com, c@gitlab.com, d@gitlab.com, and e@gitlab.com will be notified of your comment')
      end
    end
  end
end
