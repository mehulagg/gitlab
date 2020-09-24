# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Epic show', :js do
  let_it_be(:user) { create(:user, name: 'Rick Sanchez', username: 'rick.sanchez') }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:public_project) { create(:project, :public, group: group) }
  let_it_be(:label1) { create(:group_label, group: group, title: 'bug') }
  let_it_be(:label2) { create(:group_label, group: group, title: 'enhancement') }
  let_it_be(:label3) { create(:group_label, group: group, title: 'documentation') }
  let_it_be(:public_issue) { create(:issue, project: public_project) }
  let_it_be(:epic_title) { 'Sample epic' }

  let_it_be(:markdown) do
    <<-MARKDOWN.strip_heredoc
    Lorem ipsum dolor sit amet, consectetur adipiscing elit.
    Nos commodius agimus.
    Ex rebus enim timiditas, non ex vocabulis nascitur.
    Ita prorsus, inquam; Duo Reges: constructio interrete.
    MARKDOWN
  end

  let_it_be(:epic) { create(:epic, group: group, title: epic_title, description: markdown, author: user) }
  let_it_be(:not_child) { create(:epic, group: group, title: 'not child epic', description: markdown, author: user, start_date: 50.days.ago, end_date: 10.days.ago) }
  let_it_be(:child_epic_a) { create(:epic, group: group, title: 'Child epic A', description: markdown, parent: epic, start_date: 50.days.ago, end_date: 10.days.ago) }
  let_it_be(:child_epic_b) { create(:epic, group: group, title: 'Child epic B', description: markdown, parent: epic, start_date: 100.days.ago, end_date: 20.days.ago) }
  let_it_be(:child_issue_a) { create(:epic_issue, epic: epic, issue: public_issue, relative_position: 1) }

  before do
    group.add_developer(user)
    stub_licensed_features(epics: true, subepics: true)
    sign_in(user)

    visit group_epic_path(group, epic)
  end

  describe 'when sub-epics feature is available' do
    describe 'Epic metadata' do
      it 'shows epic tabs `Epics and Issues` and `Roadmap`' do
        page.within('.js-epic-tabs-container') do
          expect(find('.epic-tabs #tree-tab')).to have_content('Epics and Issues')
          expect(find('.epic-tabs #roadmap-tab')).to have_content('Roadmap')
        end
      end
    end

    describe 'Epics and Issues tab' do
      it 'shows Related items tree with child epics' do
        page.within('.js-epic-tabs-content #tree') do
          expect(page).to have_selector('.related-items-tree-container')

          page.within('.related-items-tree-container') do
            expect(page.find('.issue-count-badge', text: '2')).to be_present
            expect(find('.tree-item:nth-child(1) .sortable-link')).to have_content('Child epic B')
            expect(find('.tree-item:nth-child(2) .sortable-link')).to have_content('Child epic A')
          end
        end
      end
    end

    describe 'Roadmap tab' do
      before do
        find('.js-epic-tabs-container #roadmap-tab').click
        wait_for_requests
      end

      it 'shows Roadmap timeline with child epics' do
        page.within('.js-epic-tabs-content #roadmap') do
          expect(page).to have_selector('.roadmap-container .roadmap-shell')

          page.within('.roadmap-shell .epics-list-section') do
            expect(page).not_to have_content(not_child.title)
            expect(find('.epic-item-container:nth-child(1) .epics-list-item .epic-title')).to have_content('Child epic B')
            expect(find('.epic-item-container:nth-child(2) .epics-list-item .epic-title')).to have_content('Child epic A')
          end
        end
      end

      it 'does not show thread filter dropdown' do
        expect(find('.js-noteable-awards')).to have_selector('.js-discussion-filter-container', visible: false)
      end

      it 'has no limit on container width' do
        expect(find('.content-wrapper .container-fluid:not(.breadcrumbs)')[:class]).not_to include('container-limited')
      end
    end
  end

  describe 'when sub-epics feature not is available' do
    before do
      stub_licensed_features(epics: true, subepics: false)

      visit group_epic_path(group, epic)
    end

    describe 'Epic metadata' do
      it 'shows epic tab `Issues`' do
        page.within('.js-epic-tabs-container') do
          expect(find('.epic-tabs #tree-tab')).to have_content('Issues')
        end
      end
    end

    describe 'Issues tab' do
      it 'shows Related items tree with child epics' do
        page.within('.js-epic-tabs-content #tree') do
          expect(page).to have_selector('.related-items-tree-container')

          page.within('.related-items-tree-container') do
            expect(page.find('.issue-count-badge', text: '1')).to be_present
          end
        end
      end
    end
  end

  describe 'Epic metadata' do
    it 'shows epic status, date and author in header' do
      page.within('.epic-page-container .detail-page-header-body') do
        expect(find('.issuable-status-box > span')).to have_content('Open')
        expect(find('.issuable-meta')).to have_content('Opened')
        expect(find('.issuable-meta .js-user-avatar-link-username')).to have_content('Rick Sanchez')
      end
    end

    it 'shows epic title and description' do
      page.within('.epic-page-container .detail-page-description') do
        expect(find('.title-container .title')).to have_content(epic_title)
        expect(find('.description .md')).to have_content(markdown.squish)
      end
    end

    it 'shows epic thread filter dropdown' do
      page.within('.js-noteable-awards') do
        expect(find('.js-discussion-filter-container #discussion-filter-dropdown')).to have_content('Show all activity')
      end
    end

    describe 'Sort dropdown' do
      let!(:notes) { create_list(:note, 2, noteable: epic) }

      context 'when sorted by `Oldest first`' do
        it 'shows comments in the correct order' do
          page.within('[data-testid="sort-discussion-filter"]') do
            expect(find('.js-dropdown-text')).to have_content('Oldest first')
          end

          items = all('.timeline-entry .timeline-discussion-body .note-text')
          expect(items[0]).to have_content(notes[0].note)
          expect(items[1]).to have_content(notes[1].note)
        end
      end

      context 'when sorted by `Newest first`' do
        before do
          page.within('[data-testid="sort-discussion-filter"]') do
            find('button').click
            find('.js-newest-first').click
            wait_for_requests
          end
        end

        it 'shows comments in the correct order', quarantine: 'https://gitlab.com/gitlab-org/gitlab/-/issues/225637' do
          page.within('[data-testid="sort-discussion-filter"]') do
            expect(find('.js-dropdown-text')).to have_content('Newest first')
          end

          items = all('.timeline-entry .timeline-discussion-body .note-text')
          expect(items[0]).to have_content(notes[1].note)
          expect(items[1]).to have_content(notes[0].note)
        end
      end
    end
  end

  describe 'Epic sidebar' do
    describe 'Labels select' do
      it 'opens dropdown when `Edit` is clicked' do
        page.within('aside.right-sidebar') do
          find('.js-sidebar-dropdown-toggle').click
        end

        wait_for_requests

        expect(page).to have_css('.js-labels-block .js-labels-list')
      end

      context 'when dropdown is open' do
        before do
          page.within('aside.right-sidebar') do
            find('.js-sidebar-dropdown-toggle').click
          end
          wait_for_requests
        end

        it 'shows labels within the label dropdown' do
          page.within('.js-labels-list .dropdown-content') do
            expect(page).to have_selector('li', count: 3)
          end
        end

        it 'shows checkmark next to label when label is clicked' do
          page.within('.js-labels-list .dropdown-content') do
            find('li', text: label1.title).click

            expect(find('li', text: label1.title)).to have_selector('.gl-icon', visible: true)
          end
        end

        it 'shows label create view when `Create group label` is clicked' do
          page.within('.js-labels-block') do
            find('a', text: 'Create group label').click

            expect(page).to have_selector('.js-labels-create')
          end
        end

        it 'creates new label using create view' do
          page.within('.js-labels-block') do
            find('a', text: 'Create group label').click

            find('.dropdown-input .gl-form-input').set('Test label')
            find('.suggest-colors-dropdown a', match: :first).click
            find('.dropdown-actions button', text: 'Create').click

            wait_for_requests
          end

          page.within('.js-labels-list .dropdown-content') do
            expect(page).to have_selector('li', count: 4)
            expect(page).to have_content('Test label')
          end
        end

        it 'shows labels list view when `Cancel` button is clicked from create view' do
          page.within('.js-labels-block') do
            find('a', text: 'Create group label').click

            find('.js-btn-cancel-create').click
            wait_for_requests

            expect(page).to have_selector('.js-labels-list')
          end
        end

        it 'shows labels list view when back button is clicked from create view' do
          page.within('.js-labels-block') do
            find('a', text: 'Create group label').click

            find('.js-btn-back').click
            wait_for_requests

            expect(page).to have_selector('.js-labels-list')
          end
        end
      end
    end
  end
end
