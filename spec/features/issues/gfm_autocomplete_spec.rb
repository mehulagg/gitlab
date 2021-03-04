# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GFM autocomplete', :js do
  let_it_be(:user) { create(:user, name: '💃speciąl someone💃', username: 'someone.special') }
  let_it_be(:user2) { create(:user, name: 'Marge Simpson', username: 'msimpson') }

  let_it_be(:group) { create(:group, name: 'Ancestor') }
  let_it_be(:child_group) { create(:group, parent: group, name: 'My group') }

  let_it_be(:project) { create(:project, group: child_group) }

  let_it_be(:issue) { create(:issue, project: project, assignees: [user]) }
  let_it_be(:discussion) { create(:discussion_note_on_issue, noteable: issue, project: issue.project) }

  let_it_be(:label) { create(:label, project: project, title: 'special+') }
  let_it_be(:label_scoped) { create(:label, project: project, title: 'scoped::label') }
  let_it_be(:label_with_spaces) { create(:label, project: project, title: 'Accepting merge requests') }

  let_it_be(:milestone) { create(:milestone, project: project) }
  let_it_be(:snippet) { create(:project_snippet, project: project, title: 'code snippet') }

  before_all do
    project.add_maintainer(user)
    project.add_maintainer(user2)
  end

  describe 'when tribute_autocomplete feature flag is off' do
    describe 'new issue page' do
      before do
        stub_feature_flags(tribute_autocomplete: false)

        sign_in(user)
        visit new_project_issue_path(project)

        wait_for_requests
      end

      it 'allows quick actions' do
        fill_in 'Description', with: '/'

        expect(find_autocomplete_menu).to be_visible
      end
    end

    describe 'issue description' do
      let(:issue_to_edit) { create(:issue, project: project) }

      before do
        stub_feature_flags(tribute_autocomplete: false)

        sign_in(user)
        visit project_issue_path(project, issue_to_edit)

        wait_for_requests
      end

      it 'updates with GFM reference' do
        click_button 'Edit title and description'

        wait_for_requests

        fill_in 'Description', with: "@#{user.name[0...3]}"

        wait_for_requests

        find_highlighted_autocomplete_item.click

        click_button 'Save changes'

        wait_for_requests

        expect(find('.description')).to have_text(user.to_reference)
      end

      it 'allows quick actions' do
        click_button 'Edit title and description'

        fill_in 'Description', with: '/'

        expect(find_autocomplete_menu).to be_visible
      end
    end

    describe 'issue comment' do
      before do
        stub_feature_flags(tribute_autocomplete: false)

        sign_in(user)
        visit project_issue_path(project, issue)

        wait_for_requests
      end

      describe 'triggering autocomplete' do
        it 'only opens autocomplete menu when trigger character is after whitespace', :aggregate_failures do
          fill_in 'Comment', with: 'testing@'
          expect(page).not_to have_css('.atwho-view')

          fill_in 'Comment', with: '@@'
          expect(page).not_to have_css('.atwho-view')

          fill_in 'Comment', with: "@#{user.username[0..2]}!"
          expect(page).not_to have_css('.atwho-view')

          fill_in 'Comment', with: "hello:#{user.username[0..2]}"
          expect(page).not_to have_css('.atwho-view')

          fill_in 'Comment', with: '7:'
          expect(page).not_to have_css('.atwho-view')

          fill_in 'Comment', with: 'w:'
          expect(page).not_to have_css('.atwho-view')

          fill_in 'Comment', with: 'Ё:'
          expect(page).not_to have_css('.atwho-view')

          fill_in 'Comment', with: "test\n\n@"
          expect(find_autocomplete_menu).to be_visible
        end
      end

      describe 'autocomplete highlighting' do
        it 'auto-selects the first item with query, and only for assignees with no query', :aggregate_failures do
          fill_in 'Comment', with: ':'
          wait_for_requests
          expect(find_autocomplete_menu).not_to have_css('.cur')

          fill_in 'Comment', with: ':1'
          wait_for_requests
          expect(find_autocomplete_menu).to have_css('.cur:first-of-type')

          fill_in 'Comment', with: '@'
          wait_for_requests
          expect(find_autocomplete_menu).to have_css('.cur:first-of-type')
        end
      end

      describe 'assignees' do
        it 'does not wrap with quotes for assignee values' do
          fill_in 'Comment', with: "@#{user.username[0..2]}"

          find_highlighted_autocomplete_item.click

          expect(find_field('Comment').value).to have_text("@#{user.username}")
        end

        it 'includes items for assignee dropdowns with non-ASCII characters in name' do
          fill_in 'Comment', with: "@#{user.name[0...8]}"

          wait_for_requests

          expect(find_autocomplete_menu).to have_text(user.name)
        end

        it 'searches across full name for assignees' do
          fill_in 'Comment', with: '@speciąlsome'

          wait_for_requests

          expect(find_highlighted_autocomplete_item).to have_text(user.name)
        end

        it 'shows names that start with the query as the top result' do
          fill_in 'Comment', with: '@mar'

          wait_for_requests

          expect(find_highlighted_autocomplete_item).to have_text(user2.name)
        end

        it 'shows usernames that start with the query as the top result' do
          fill_in 'Comment', with: '@msi'

          wait_for_requests

          expect(find_highlighted_autocomplete_item).to have_text(user2.name)
        end

        # Regression test for https://gitlab.com/gitlab-org/gitlab/-/issues/321925
        it 'shows username when pasting then pressing Enter' do
          fill_in 'Comment', with: "@#{user.username}\n"

          expect(find_field('Comment').value).to have_text "@#{user.username}"
        end

        it 'does not show `@undefined` when pressing `@` then Enter' do
          fill_in 'Comment', with: "@\n"

          expect(find_field('Comment').value).to have_text '@'
          expect(find_field('Comment').value).not_to have_text '@undefined'
        end

        context 'when using assignees quick action' do
          context 'with /assign' do
            it 'triggers user autocomplete when selected and lists users who are currently not assigned to the issue' do
              fill_in 'Comment', with: '/as'

              find_highlighted_autocomplete_item.click

              expect(find_autocomplete_menu).to have_text(user2.username)
              expect(find_autocomplete_menu).not_to have_text(user.username)
            end
          end

          context 'with /unassign' do
            it 'triggers user autocomplete when selected and lists users who are currently assigned to the issue' do
              fill_in 'Comment', with: '/unas'

              find_highlighted_autocomplete_item.click

              expect(find_autocomplete_menu).to have_text(user.username)
              expect(find_autocomplete_menu).not_to have_text(user2.username)
            end
          end
        end
      end

      context 'labels' do
        it 'wraps the result in double quotes when there is a non-word character in the title' do
          fill_in 'Comment', with: "~#{label.title[0..2]}"

          find_highlighted_autocomplete_item.click

          expect(find_field('Comment').value).to have_text("~\"#{label.title}\"")
        end

        it 'allows colons when autocompleting scoped labels' do
          fill_in 'Comment', with: '~scoped::'

          wait_for_requests

          expect(find_autocomplete_menu).to have_text('scoped::label')
        end

        it 'allows spaces when autocompleting multi-word labels' do
          fill_in 'Comment', with: '~Accepting merge'

          wait_for_requests

          expect(find_autocomplete_menu).to have_text('Accepting merge requests')
        end

        it 'only autocompletes the last label' do
          fill_in 'Comment', with: '~scoped:: foo bar ~Accepting merge'

          wait_for_requests

          expect(find_autocomplete_menu).to have_text('Accepting merge requests')
        end
      end

      context 'quick actions' do
        it 'does not limit quick actions autocomplete list to default of 5' do
          fill_in 'Comment', with: '/'

          expect(find_autocomplete_menu).to have_css('li', minimum: 6)
        end
      end

      context 'when other notes are destroyed' do
        # This is meant to protect against this issue https://gitlab.com/gitlab-org/gitlab/-/issues/228729
        it 'keeps autocomplete key listeners' do
          note = find_field('Comment')

          start_comment_with_emoji(note, '.atwho-view li')

          start_and_cancel_discussion

          note.fill_in(with: '')
          start_comment_with_emoji(note, '.atwho-view li')
          note.native.send_keys(:enter)

          expect(note.value).to eql('Hello :100: ')
        end
      end

      shared_examples 'autocomplete suggestions' do
        it 'suggests objects correctly' do
          fill_in 'Comment', with: object.class.reference_prefix

          find_autocomplete_menu.find('li').click

          expect(find_field('Comment').value).to have_text(expected_body)
        end
      end

      context 'issues' do
        let(:object) { issue }
        let(:expected_body) { object.to_reference }

        it_behaves_like 'autocomplete suggestions'
      end

      context 'merge requests' do
        let(:object) { create(:merge_request, source_project: project) }
        let(:expected_body) { object.to_reference }

        it_behaves_like 'autocomplete suggestions'
      end

      context 'project snippets' do
        let!(:object) { snippet }
        let(:expected_body) { object.to_reference }

        it_behaves_like 'autocomplete suggestions'
      end

      context 'milestone' do
        let!(:object) { milestone }
        let(:expected_body) { object.to_reference }

        it_behaves_like 'autocomplete suggestions'
      end
    end
  end

  describe 'when tribute_autocomplete feature flag is on' do
    describe 'issue description' do
      let(:issue_to_edit) { create(:issue, project: project) }

      before do
        stub_feature_flags(tribute_autocomplete: true)

        sign_in(user)
        visit project_issue_path(project, issue_to_edit)

        wait_for_requests
      end

      it 'updates with GFM reference' do
        click_button 'Edit title and description'

        wait_for_requests

        fill_in 'Description', with: "@#{user.name[0...3]}"

        wait_for_requests

        find_highlighted_tribute_autocomplete_menu.click

        click_button 'Save changes'

        wait_for_requests

        expect(find('.description')).to have_text(user.to_reference)
      end
    end

    describe 'issue comment' do
      before do
        stub_feature_flags(tribute_autocomplete: true)

        sign_in(user)
        visit project_issue_path(project, issue)

        wait_for_requests
      end

      describe 'triggering autocomplete' do
        it 'only opens autocomplete menu when trigger character is after whitespace', :aggregate_failures do
          fill_in 'Comment', with: 'testing@'
          expect(page).not_to have_css('.tribute-container')

          fill_in 'Comment', with: "hello:#{user.username[0..2]}"
          expect(page).not_to have_css('.tribute-container')

          fill_in 'Comment', with: '7:'
          expect(page).not_to have_css('.tribute-container')

          fill_in 'Comment', with: 'w:'
          expect(page).not_to have_css('.tribute-container')

          fill_in 'Comment', with: 'Ё:'
          expect(page).not_to have_css('.tribute-container')

          fill_in 'Comment', with: "test\n\n@"
          expect(find_tribute_autocomplete_menu).to be_visible
        end
      end

      describe 'autocomplete highlighting' do
        it 'auto-selects the first item with query, and only for assignees with no query', :aggregate_failures do
          fill_in 'Comment', with: ':'
          wait_for_requests
          expect(find_tribute_autocomplete_menu).not_to have_css('.cur')

          fill_in 'Comment', with: ':1'
          wait_for_requests
          expect(find_tribute_autocomplete_menu).to have_css('.highlight:first-of-type')

          fill_in 'Comment', with: '@'
          wait_for_requests
          expect(find_tribute_autocomplete_menu).to have_css('.highlight:first-of-type')
        end
      end

      describe 'assignees' do
        it 'does not wrap with quotes for assignee values' do
          fill_in 'Comment', with: "@#{user.username[0..2]}"

          find_highlighted_tribute_autocomplete_menu.click

          expect(find_field('Comment').value).to have_text("@#{user.username}")
        end

        it 'includes items for assignee dropdowns with non-ASCII characters in name' do
          fill_in 'Comment', with: "@#{user.name[0...8]}"

          wait_for_requests

          expect(find_tribute_autocomplete_menu).to have_text(user.name)
        end

        it 'searches across full name for assignees' do
          fill_in 'Comment', with: '@speciąlsome'

          wait_for_requests

          expect(find_highlighted_tribute_autocomplete_menu).to have_text(user.name)
        end

        it 'shows names that start with the query as the top result' do
          fill_in 'Comment', with: '@mar'

          wait_for_requests

          expect(find_highlighted_tribute_autocomplete_menu).to have_text(user2.name)
        end

        it 'shows usernames that start with the query as the top result' do
          fill_in 'Comment', with: '@msi'

          wait_for_requests

          expect(find_highlighted_tribute_autocomplete_menu).to have_text(user2.name)
        end

        # Regression test for https://gitlab.com/gitlab-org/gitlab/-/issues/321925
        it 'shows username when pasting then pressing Enter' do
          fill_in 'Comment', with: "@#{user.username}\n"

          expect(find_field('Comment').value).to have_text "@#{user.username}"
        end

        it 'does not show `@undefined` when pressing `@` then Enter' do
          fill_in 'Comment', with: "@\n"

          expect(find_field('Comment').value).to have_text '@'
          expect(find_field('Comment').value).not_to have_text '@undefined'
        end

        context 'when autocompleting for groups' do
          it 'shows the group when searching for the name of the group' do
            fill_in 'Comment', with: '@mygroup'

            expect(find_tribute_autocomplete_menu).to have_text('My group')
          end

          it 'does not show the group when searching for the name of the parent of the group' do
            fill_in 'Comment', with: '@ancestor'

            expect(find_tribute_autocomplete_menu).not_to have_text('My group')
          end
        end

        context 'when using assignees quick action' do
          context 'with /assign' do
            it 'lists users who are currently not assigned to the issue' do
              note = find_field('Comment')
              note.native.send_keys('/assign ')
              # The `/assign` ajax response might replace the one by `@` below causing a failed test
              # so we need to wait for the `/assign` ajax request to finish first
              wait_for_requests
              note.native.send_keys('@')
              wait_for_requests

              expect(find_tribute_autocomplete_menu).to have_text(user2.username)
              expect(find_tribute_autocomplete_menu).not_to have_text(user.username)
            end

            it 'lists users who are currently not assigned to the issue on the second line' do
              note = find_field('Comment')
              note.native.send_keys('/assign @user2')
              note.native.send_keys(:enter)
              note.native.send_keys('/assign ')
              # The `/assign` ajax response might replace the one by `@` below causing a failed test
              # so we need to wait for the `/assign` ajax request to finish first
              wait_for_requests
              note.native.send_keys('@')
              wait_for_requests

              expect(find_tribute_autocomplete_menu).to have_text(user2.username)
              expect(find_tribute_autocomplete_menu).not_to have_text(user.username)
            end
          end

          context 'with /unassign' do
            it 'lists users who are currently assigned to the issue' do
              note = find_field('Comment')
              note.native.send_keys('/unassign ')
              # The `/assign` ajax response might replace the one by `@` below causing a failed test
              # so we need to wait for the `/assign` ajax request to finish first
              wait_for_requests
              note.native.send_keys('@')
              wait_for_requests

              expect(find_tribute_autocomplete_menu).to have_text(user.username)
              expect(find_tribute_autocomplete_menu).not_to have_text(user2.username)
            end
          end
        end
      end

      context 'labels' do
        it 'wraps the result in double quotes when there is a non-word character in the title' do
          fill_in 'Comment', with: "~#{label.title[0..2]}"

          find_highlighted_tribute_autocomplete_menu.click

          expect(find_field('Comment').value).to have_text("~\"#{label.title}\"")
        end

        it 'allows colons when autocompleting scoped labels' do
          fill_in 'Comment', with: '~scoped::'

          wait_for_requests

          expect(find_tribute_autocomplete_menu).to have_text('scoped::label')
        end

        it 'autocompletes multi-word labels' do
          fill_in 'Comment', with: '~Acceptingmerge'

          wait_for_requests

          expect(find_tribute_autocomplete_menu).to have_text('Accepting merge requests')
        end

        it 'only autocompletes the latest label' do
          fill_in 'Comment', with: '~scoped:: foo bar ~Acceptingmerge'
          # Invoke autocompletion
          find_field('Comment').native.send_keys(:right)

          wait_for_requests

          expect(find_tribute_autocomplete_menu).to have_text('Accepting merge requests')
        end
      end

      context 'quick actions' do
        it 'does not limit quick actions autocomplete list to default of 5' do
          fill_in 'Comment', with: '/'

          expect(find_tribute_autocomplete_menu).to have_css('li', minimum: 6)
        end
      end

      context 'when other notes are destroyed' do
        # This is meant to protect against this issue https://gitlab.com/gitlab-org/gitlab/-/issues/228729
        it 'keeps autocomplete key listeners' do
          note = find_field('Comment')

          start_comment_with_emoji(note, '.tribute-container li')

          start_and_cancel_discussion

          note.fill_in(with: '')
          start_comment_with_emoji(note, '.tribute-container li')
          note.native.send_keys(:enter)

          expect(note.value).to eql('Hello :100: ')
        end
      end

      shared_examples 'autocomplete suggestions' do
        it 'suggests objects correctly' do
          fill_in 'Comment', with: object.class.reference_prefix

          find_tribute_autocomplete_menu.find('li').click

          expect(find_field('Comment').value).to have_text(expected_body)
        end
      end

      context 'issues' do
        let(:object) { issue }
        let(:expected_body) { object.to_reference }

        it_behaves_like 'autocomplete suggestions'
      end

      context 'merge requests' do
        let(:object) { create(:merge_request, source_project: project) }
        let(:expected_body) { object.to_reference }

        it_behaves_like 'autocomplete suggestions'
      end

      context 'project snippets' do
        let!(:object) { snippet }
        let(:expected_body) { object.to_reference }

        it_behaves_like 'autocomplete suggestions'
      end

      context 'milestone' do
        let!(:object) { milestone }
        let(:expected_body) { object.to_reference }

        it_behaves_like 'autocomplete suggestions'
      end
    end
  end

  private

  def start_comment_with_emoji(note, selector)
    note.native.send_keys('Hello :10')

    wait_for_requests

    find(selector, text: '100')
  end

  def start_and_cancel_discussion
    fill_in('Reply to comment', with: 'Whoops!')

    page.accept_alert 'Are you sure you want to cancel creating this comment?' do
      click_button('Cancel')
    end

    wait_for_requests
  end

  def find_autocomplete_menu
    find('.atwho-view ul', visible: true)
  end

  def find_highlighted_autocomplete_item
    find('.atwho-view li.cur', visible: true)
  end

  def find_tribute_autocomplete_menu
    find('.tribute-container ul', visible: true)
  end

  def find_highlighted_tribute_autocomplete_menu
    find('.tribute-container li.highlight', visible: true)
  end
end
