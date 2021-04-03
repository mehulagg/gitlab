# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Group issues page' do
  let(:group) { create(:group) }
  let(:project) { create(:project, :public, group: group)}

  context 'bulk editing', :js do
    let(:user_in_group) { create(:group_member, :maintainer, user: create(:user), group: group ).user }
    let!(:milestone) { create(:milestone, group: group) }
    let!(:issue) { create(:issue, project: project) }

    before do
      sign_in(user_in_group)
      visit issues_group_path(group)
    end

    it 'shows sidebar when clicked on "Edit issues"' do
      find('.js-bulk-update-toggle').click

      page.within('.js-right-sidebar') do
        expect(page).to have_selector('.issuable-sidebar', visible: true)
      end
    end

    it 'shows group milestones within "Milestone" dropdown' do
      find('.js-bulk-update-toggle').click

      page.within('.js-right-sidebar') do
        find('button.js-milestone-select').click
        wait_for_requests

        page.within('.dropdown-menu-milestone .dropdown-content') do
          expect(page).to have_content(milestone.title)
        end
      end
    end
  end
end
