# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Issue Sidebar' do
  include MobileHelpers

  let(:group) { create(:group, :nested) }
  let(:project) { create(:project, :public, namespace: group) }
  let!(:user) { create(:user) }
  let!(:label) { create(:label, project: project, title: 'bug') }
  let(:issue) { create(:labeled_issue, project: project, labels: [label]) }
  let!(:xss_label) { create(:label, project: project, title: '&lt;script&gt;alert("xss");&lt;&#x2F;script&gt;') }
  let!(:milestone_expired) { create(:milestone, project: project, due_date: 5.days.ago) }
  let!(:milestone_no_duedate) { create(:milestone, project: project, title: 'Foo - No due date') }
  let!(:milestone1) { create(:milestone, project: project, title: 'Milestone-1', due_date: 20.days.from_now) }
  let!(:milestone2) { create(:milestone, project: project, title: 'Milestone-2', due_date: 15.days.from_now) }
  let!(:milestone3) { create(:milestone, project: project, title: 'Milestone-3', due_date: 10.days.from_now) }

  before do
    stub_incoming_email_setting(enabled: true, address: "p+%{key}@gl.ab")
  end

  context 'when signed in' do
    before do
      sign_in(user)
    end

    context 'when concerning the assignee', :js do
      let(:user2) { create(:user) }
      let(:issue2) { create(:issue, project: project, author: user2) }

      # include_examples 'issuable invite members experiments' do
      #   let(:issuable_path) { project_issue_path(project, issue2) }
      # end

      context 'when user is a developer' do
        before do
          project.add_developer(user)
          visit_issue(project, issue2)
        end

        it 'shows author in assignee dropdown' do
          page.within('.assignee') do
            click_button('Edit')
            wait_for_requests
          end

          page.within '.dropdown-menu-user' do
            expect(page).to have_content(user2.name)
          end
        end

        it 'shows author when filtering assignee dropdown' do
          page.within('.assignee') do
            click_button('Edit')
            wait_for_requests
          end

          page.within '.dropdown-menu-user' do
            find('.js-dropdown-input-field').find('input').set(user2.name)

            wait_for_requests

            expect(page).to have_content(user2.name)
          end
        end

        it 'assigns yourself' do
          click_button 'assign yourself'
          wait_for_requests

          page.within '.assignee' do
            expect(page).to have_content(user.name)
          end
        end

        it 'keeps your filtered term after filtering and dismissing the dropdown' do
          page.within('.assignee') do
            click_button('Edit')
            wait_for_requests
          end

          find('.js-dropdown-input-field').find('input').set(user2.name)

          wait_for_requests

          page.within '.dropdown-menu-user' do
            expect(page).not_to have_content 'Unassigned'
            click_link user2.name
          end

          find('.js-right-sidebar').click
          page.within('.assignee') do
            click_button('Edit')
            wait_for_requests
          end

          expect(page.all('.dropdown-menu-user li').length).to eq(1)
          expect(find('.dropdown-input-field').value).to eq(user2.name)
        end
      end

      it 'shows label text as "Apply" when assignees are changed' do
        project.add_developer(user)
        visit_issue(project, issue2)

        page.within('.assignee') do
          click_button('Edit')
          wait_for_requests
        end

        click_on 'Unassigned'

        expect(page).to have_link('Apply')
      end
    end

    context 'as a allowed user' do
      before do
        project.add_developer(user)
        visit_issue(project, issue)
      end

      context 'sidebar', :js do
        it 'changes size when the screen size is smaller' do
          sidebar_selector = 'aside.right-sidebar.right-sidebar-collapsed'
          # Resize the window
          resize_screen_sm
          # Make sure the sidebar is collapsed
          find(sidebar_selector)
          expect(page).to have_css(sidebar_selector)
          # Once is collapsed let's open the sidebard and reload
          open_issue_sidebar
          refresh
          find(sidebar_selector)
          expect(page).to have_css(sidebar_selector)
          # Restore the window size as it was including the sidebar
          restore_window_size
          open_issue_sidebar
        end

        it 'escapes XSS when viewing issue labels' do
          page.within('.block.labels') do
            click_on 'Edit'

            expect(page).to have_content '<script>alert("xss");</script>'
          end
        end
      end

      context 'editing issue milestone', :js do
        before do
          page.within('.block.milestone > .title') do
            click_on 'Edit'
          end
        end

        it 'shows milestons list in the dropdown' do
          page.within('.block.milestone .dropdown-content') do
            # 5 milestones + "No milestone" = 6 items
            expect(page.find('ul')).to have_selector('li[data-milestone-id]', count: 6)
          end
        end

        it 'shows expired milestone at the bottom of the list' do
          page.within('.block.milestone .dropdown-content ul') do
            expect(page.find('li:last-child')).to have_content milestone_expired.title
          end
        end

        it 'shows milestone due earliest at the top of the list' do
          page.within('.block.milestone .dropdown-content ul') do
            expect(page.all('li[data-milestone-id]')[1]).to have_content milestone3.title
            expect(page.all('li[data-milestone-id]')[2]).to have_content milestone2.title
            expect(page.all('li[data-milestone-id]')[3]).to have_content milestone1.title
            expect(page.all('li[data-milestone-id]')[4]).to have_content milestone_no_duedate.title
          end
        end
      end

      context 'editing issue labels', :js do
        before do
          issue.update(labels: [label])
          page.within('.block.labels') do
            click_on 'Edit'
          end
        end

        it 'shows the current set of labels' do
          page.within('.issuable-show-labels') do
            expect(page).to have_content label.title
          end
        end

        it 'shows option to create a project label' do
          page.within('.block.labels') do
            expect(page).to have_content 'Create project'
          end
        end

        context 'creating a project label', :js, quarantine: 'https://gitlab.com/gitlab-org/gitlab/-/issues/27992' do
          before do
            page.within('.block.labels') do
              click_link 'Create project'
            end
          end

          it 'shows dropdown switches to "create label" section' do
            page.within('.block.labels') do
              expect(page).to have_content 'Create project label'
            end
          end

          it 'adds new label' do
            page.within('.block.labels') do
              fill_in 'new_label_name', with: 'wontfix'
              page.find('.suggest-colors a', match: :first).click
              page.find('button', text: 'Create').click

              page.within('.dropdown-page-one') do
                expect(page).to have_content 'wontfix'
              end
            end
          end

          it 'shows error message if label title is taken' do
            page.within('.block.labels') do
              fill_in 'new_label_name', with: label.title
              page.find('.suggest-colors a', match: :first).click
              page.find('button', text: 'Create').click

              page.within('.dropdown-page-two') do
                expect(page).to have_content 'Title has already been taken'
              end
            end
          end
        end
      end

      context 'interacting with collapsed sidebar', :js do
        collapsed_sidebar_selector = 'aside.right-sidebar.right-sidebar-collapsed'
        expanded_sidebar_selector = 'aside.right-sidebar.right-sidebar-expanded'
        confidentiality_sidebar_block = '.block.confidentiality'
        lock_sidebar_block = '.block.lock'
        collapsed_sidebar_block_icon = '.sidebar-collapsed-icon'

        before do
          resize_screen_sm
        end

        it 'confidentiality block expands then collapses sidebar' do
          expect(page).to have_css(collapsed_sidebar_selector)

          page.within(confidentiality_sidebar_block) do
            find(collapsed_sidebar_block_icon).click
          end

          expect(page).to have_css(expanded_sidebar_selector)

          page.within(confidentiality_sidebar_block) do
            page.find('button', text: 'Cancel').click
          end

          expect(page).to have_css(collapsed_sidebar_selector)
        end

        it 'lock block expands then collapses sidebar' do
          expect(page).to have_css(collapsed_sidebar_selector)

          page.within(lock_sidebar_block) do
            find(collapsed_sidebar_block_icon).click
          end

          expect(page).to have_css(expanded_sidebar_selector)

          page.within(lock_sidebar_block) do
            page.find('button', text: 'Cancel').click
          end

          expect(page).to have_css(collapsed_sidebar_selector)
        end
      end
    end

    context 'as a guest' do
      before do
        project.add_guest(user)
        visit_issue(project, issue)
      end

      it 'does not have a option to edit labels' do
        expect(page).not_to have_selector('.block.labels .js-sidebar-dropdown-toggle')
      end

      context 'sidebar', :js do
        it 'finds issue copy forwarding email' do
          expect(find('[data-qa-selector="copy-forward-email"]').text).to eq "Issue email: #{issue.creatable_note_email_address(user)}"
        end
      end

      context 'interacting with collapsed sidebar', :js do
        collapsed_sidebar_selector = 'aside.right-sidebar.right-sidebar-collapsed'
        expanded_sidebar_selector = 'aside.right-sidebar.right-sidebar-expanded'
        lock_sidebar_block = '.block.lock'
        lock_button = '.block.lock .btn-close'
        collapsed_sidebar_block_icon = '.sidebar-collapsed-icon'

        before do
          resize_screen_sm
        end

        it 'expands then does not show the lock dialog form' do
          expect(page).to have_css(collapsed_sidebar_selector)

          page.within(lock_sidebar_block) do
            find(collapsed_sidebar_block_icon).click
          end

          expect(page).to have_css(expanded_sidebar_selector)
          expect(page).not_to have_selector(lock_button)
        end
      end
    end
  end

  context 'when not signed in' do
    context 'sidebar', :js do
      before do
        visit_issue(project, issue)
      end

      it 'does not find issue email' do
        expect(page).not_to have_selector('[data-qa-selector="copy-forward-email"]')
      end
    end
  end

  def visit_issue(project, issue)
    visit project_issue_path(project, issue)
  end

  def open_issue_sidebar
    find('aside.right-sidebar.right-sidebar-collapsed .js-sidebar-toggle').click
    find('aside.right-sidebar.right-sidebar-expanded')
  end
end
