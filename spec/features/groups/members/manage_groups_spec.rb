# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Groups > Members > Manage groups', :js do
  include Select2Helper
  include Spec::Support::Helpers::Features::ListRowsHelpers

  let(:user) { create(:user) }
  let(:shared_with_group) { create(:group) }
  let(:shared_group) { create(:group) }

  before do
    stub_feature_flags(vue_group_members_list: false)

    shared_group.add_owner(user)
    sign_in(user)
  end

  it 'add group to group' do
    visit group_group_members_path(shared_group)

    add_group(shared_with_group.id, 'Reporter')

    click_groups_tab

    page.within(first_row) do
      expect(page).to have_content(shared_with_group.name)
      expect(page).to have_content('Reporter')
    end
  end

  it 'remove group from group' do
    create(:group_group_link, shared_group: shared_group,
      shared_with_group: shared_with_group, group_access: ::Gitlab::Access::DEVELOPER)

    visit group_group_members_path(shared_group)

    click_groups_tab

    expect(page).to have_content(shared_with_group.name)

    accept_confirm do
      find(:css, '#tab-groups li', text: shared_with_group.name).find(:css, 'a.btn-remove').click
    end

    expect(page).not_to have_content(shared_with_group.name)
  end

  it 'update group to owner level' do
    create(:group_group_link, shared_group: shared_group,
      shared_with_group: shared_with_group, group_access: ::Gitlab::Access::DEVELOPER)

    visit group_group_members_path(shared_group)

    click_groups_tab

    page.within(first_row) do
      click_button('Developer')
      click_link('Maintainer')

      wait_for_requests

      expect(page).to have_button('Maintainer')
    end
  end

  it 'updates expiry date' do
    create(:group_group_link, shared_group: shared_group, shared_with_group: shared_with_group)

    visit group_group_members_path(shared_group)
    click_groups_tab

    expires_at = 3.days.from_now

    fill_in "member_expires_at_#{shared_with_group.id}", with: expires_at.strftime("%F")
    find('body').click
    wait_for_requests

    page.within(find('li.group_member')) do
      expect(page).to have_content('Expires in')
    end
  end

  it 'clears expiry date' do
    expires_at = 3.days.from_now

    create(:group_group_link, shared_group: shared_group, shared_with_group: shared_with_group, expires_at: expires_at.strftime("%F"))

    visit group_group_members_path(shared_group)
    click_groups_tab

    page.within(find('li.group_member')) do
      expect(page).to have_content('Expires in')

      page.within(find('.js-edit-member-form')) do
        find('.js-clear-input').click
      end

      wait_for_requests

      expect(page).not_to have_content('Expires in')
    end
  end

  def add_group(id, role)
    page.click_link 'Invite group'
    page.within ".invite-group-form" do
      select2(id, from: "#shared_with_group_id")
      select(role, from: "shared_group_access")
      click_button "Invite"
    end
  end

  def click_groups_tab
    click_link "Groups"
  end
end
