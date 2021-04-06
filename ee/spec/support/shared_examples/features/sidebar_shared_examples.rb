# frozen_string_literal: true

RSpec.shared_examples 'issue boards sidebar EE' do
  context 'epic dropdown' do
    let_it_be(:epic1) { create(:epic, group: group) }
    let_it_be(:epic2) { create(:epic, group: group) }

    let_it_be(:epic_issue, reload: true) { create(:epic_issue, epic: epic1, issue: issue) }

    context 'when the issue is associated with an epic' do
      before do
        first_card_with_epic.click
      end

      it 'displays name of epic and links to it' do
        page.within('[data-testid="sidebar-epic"]') do
          expect(page).to have_link(epic1.title, href: epic_path(epic1))
        end
      end

      it 'updates the epic associated with the issue' do
        page.within('[data-testid="sidebar-epic"]') do
          find("[data-testid='edit-button']").click

          wait_for_requests

          find('.gl-new-dropdown-item', text: epic2.title).click

          wait_for_requests

          expect(page).to have_link(epic2.title, href: epic_path(epic2))
        end
      end
    end
  end
end
