# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Related issues', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project_empty_repo, :public) }
  let_it_be(:project_b) { create(:project_empty_repo, :public) }
  let_it_be(:project_unauthorized) { create(:project_empty_repo, :public) }
  let_it_be(:issue_a) { create(:issue, project: project) }
  let_it_be(:issue_b) { create(:issue, project: project) }
  let_it_be(:issue_c) { create(:issue, project: project) }
  let_it_be(:issue_d) { create(:issue, project: project) }
  let_it_be(:issue_project_b_a) { create(:issue, project: project_b) }
  let_it_be(:issue_project_unauthorized_a) { create(:issue, project: project_unauthorized) }

  context 'when user has permission to manage related issues' do
    before do
      stub_feature_flags(vue_issue_header: false)

      project.add_maintainer(user)
      project_b.add_maintainer(user)
      gitlab_sign_in(user)
    end

    context 'with "Relates to", "Blocks", "Is blocked by" groupings' do
      def add_linked_issue(issue, radio_input_value)
        find('.js-issue-count-badge-add-button').click
        find('.js-add-issuable-form-input').set "#{issue.to_reference(project)} "
        find("input[name=\"linked-issue-type-radio\"][value=\"#{radio_input_value}\"]").click
        find('.js-add-issuable-form-add-button').click

        wait_for_requests
      end

      before do
        visit project_issue_path(project, issue_a)
        wait_for_requests
      end

      context 'when adding a "relates_to" issue' do
        before do
          add_linked_issue(issue_b, "relates_to")
        end

        it 'shows "Relates to" heading' do
          headings = all('.linked-issues-card-body h4')

          expect(headings.count).to eq(1)
          expect(headings[0].text).to eq("Relates to")
        end

        it 'shows the added issue' do
          items = all('.item-title a')

          expect(items[0].text).to eq(issue_b.title)
          expect(find('.js-related-issues-header-issue-count')).to have_content('1')
        end
      end

      context 'when adding a "blocks" issue' do
        before do
          add_linked_issue(issue_b, "blocks")
        end

        it 'shows "Blocks" heading' do
          headings = all('.linked-issues-card-body h4')

          expect(headings.count).to eq(1)
          expect(headings[0].text).to eq("Blocks")
        end

        it 'shows the added issue' do
          items = all('.item-title a')

          expect(items[0].text).to eq(issue_b.title)
          expect(find('.js-related-issues-header-issue-count')).to have_content('1')
        end
      end

      context 'when adding an "is_blocked_by" issue' do
        before do
          add_linked_issue(issue_b, "is_blocked_by")
        end

        it 'shows "Is blocked by" heading' do
          headings = all('.linked-issues-card-body h4')

          expect(headings.count).to eq(1)
          expect(headings[0].text).to eq("Is blocked by")
        end

        it 'shows the added issue' do
          items = all('.item-title a')

          expect(items[0].text).to eq(issue_b.title)
          expect(find('.js-related-issues-header-issue-count')).to have_content('1')
        end

        it 'hides the modal when issue is closed' do
          # Workaround for modal not showing when issue is first added
          visit project_issue_path(project, issue_a)
          wait_for_requests

          within('.new-note') do
            button = find(:button, 'Close issue')
            scroll_to(button)
            button.click
          end

          click_button 'Yes, close issue'

          wait_for_requests

          find(:button, 'Yes, close issue', visible: false)

          status_box = first('.status-box', visible: :all)
          scroll_to(status_box)

          within(status_box) do
            expect(page).to have_content 'Closed'
          end
        end
      end

      context 'when adding "relates_to", "blocks", and "is_blocked_by" issues' do
        before do
          add_linked_issue(issue_b, "relates_to")
          add_linked_issue(issue_c, "blocks")
          add_linked_issue(issue_d, "is_blocked_by")
        end

        it 'shows "Blocks", "Is blocked by", and "Relates to" headings' do
          headings = all('.linked-issues-card-body h4')

          expect(headings.count).to eq(3)
          expect(headings[0].text).to eq("Blocks")
          expect(headings[1].text).to eq("Is blocked by")
          expect(headings[2].text).to eq("Relates to")
        end

        it 'shows all added issues' do
          items = all('.item-title a')

          expect(items.count).to eq(3)
          expect(find('.js-related-issues-header-issue-count')).to have_content('3')
        end
      end
    end
  end
end
