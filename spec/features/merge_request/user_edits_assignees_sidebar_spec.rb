# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Merge request > User edits assignees sidebar', :js do
  let(:project) { create(:project, :public, :repository) }
  let(:protected_branch) { create(:protected_branch, :maintainers_can_push, name: 'master', project: project) }
  let(:merge_request) { create(:merge_request, :simple, source_project: project, target_branch: protected_branch.name) }

  let(:users_find_limit) { 5 }

  # Insert more than limit so that response doesn't include assigned user
  let(:project_developers) { Array.new(users_find_limit + 1) { create(:user).tap { |u| project.add_developer(u) } } }
  let(:project_maintainers) { Array.new(users_find_limit + 1) { create(:user).tap { |u| project.add_maintainer(u) } } }

  # DOM finders to simplify and improve readability
  let(:sidebar_assignee_block) { page.find('.js-issuable-sidebar .assignee') }
  let(:sidebar_assignee_avatar_link) { sidebar_assignee_block.find_all('a').find { |a| a['href'].include? assignee.username } }
  let(:sidebar_assignee_tooltip) { sidebar_assignee_avatar_link['title'] || '' }
  let(:sidebar_assignee_dropdown_item) { sidebar_assignee_block.find(".dropdown-menu li[data-user-id=\"#{assignee.id}\"]") }
  let(:sidebar_assignee_dropdown_tooltip) { sidebar_assignee_dropdown_item.find('a')['data-title'] || '' }

  context 'when invite_members_version_a experiment is not enabled' do
    before do
      stub_const('Autocomplete::UsersFinder::LIMIT', users_find_limit)

      sign_in(project.owner)

      merge_request.assignees << assignee

      visit project_merge_request_path(project, merge_request)

      wait_for_requests
    end

    shared_examples 'when assigned' do |expected_tooltip: ''|
      it 'shows assignee name' do
        expect(sidebar_assignee_block).to have_text(assignee.name)
      end

      it "shows assignee tooltip '#{expected_tooltip}'" do
        expect(sidebar_assignee_tooltip).to eql(expected_tooltip)
      end

      context 'when edit is clicked' do
        before do
          sidebar_assignee_block.click_link('Edit')

          wait_for_requests
        end

        it "shows assignee tooltip '#{expected_tooltip}" do
          expect(sidebar_assignee_dropdown_tooltip).to eql(expected_tooltip)
        end

        it 'does not show invite link' do
          page.within '.dropdown-menu-user' do
            expect(page).not_to have_link('Invite Members')
          end
        end
      end
    end

    context 'when assigned to maintainer' do
      let(:assignee) { project_maintainers.last }

      it_behaves_like 'when assigned', expected_tooltip: ''
    end

    context 'when assigned to developer' do
      let(:assignee) { project_developers.last }

      it_behaves_like 'when assigned', expected_tooltip: 'Cannot merge'
    end
  end

  context 'when invite_members_version_a experiment is enabled' do
    let_it_be(:user) { create(:user) }

    before do
      stub_experiment_for_user(invite_members_version_a: true)
      sign_in(user)
    end

    context 'when user can not see invite members' do
      before do
        project.add_developer(user)
        visit project_merge_request_path(project, merge_request)

        find('.block.assignee .edit-link').click

        wait_for_requests
      end

      it 'does not see link to invite members' do
        page.within '.dropdown-menu-user' do
          expect(page).not_to have_link('Invite Members')
        end
      end
    end

    context 'when user can see invite members' do
      before do
        project.add_maintainer(user)
        visit project_merge_request_path(project, merge_request)

        find('.block.assignee .edit-link').click

        wait_for_requests
      end

      it 'sees link to invite members' do
        page.within '.dropdown-menu-user' do
          expect(page).to have_link('Invite Members', href: project_project_members_path(project))
        end
      end
    end
  end
end
