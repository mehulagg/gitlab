# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Delete Epic', :js do
  let(:user) { create(:user) }
  let(:group) { create(:group, :public) }
  let(:epic) { create(:epic, group: group) }
  let!(:epic2) { create(:epic, group: group) }
  let!(:child_epic) { create(:epic, group: group, parent: epic, author: user) }

  before do
    stub_licensed_features(epics: true)

    sign_in(user)
  end

  context 'when user who is not a group member displays the epic' do
    it 'does not show the Delete button' do
      visit group_epic_path(group, epic)

      expect(page).not_to have_selector('.detail-page-header button')
    end
  end

  context 'when user with owner access displays the epic' do
    before do
      group.add_owner(user)
      visit group_epic_path(group, epic)
      wait_for_requests
      find('.js-issuable-edit').click
    end

    it 'deletes the epic and redirect to epic list' do
      page.accept_alert 'Epic will be removed! Are you sure?' do
        find(:button, text: 'Delete').click
      end

      wait_for_requests

      expect(find('.issuable-list')).not_to have_content(epic.title)
      expect(find('.issuable-list')).to have_content(epic2.title)
      # orphans child epics rather than destroying
      expect(find('.issuable-list')).to have_content(child_epic.title)
    end
  end
end
