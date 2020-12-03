# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Groups > Members > Sort members', :js do
  include Spec::Support::Helpers::Features::MembersHelpers

  let(:owner)     { create(:user, name: 'John Doe') }
  let(:developer) { create(:user, name: 'Mary Jane', last_sign_in_at: 5.days.ago) }
  let(:group)     { create(:group) }

  dropdown_toggle_selector = '[data-testid="members-sort-dropdown"] > button'

  before do
    create(:group_member, :owner, user: owner, group: group, created_at: 5.days.ago)
    create(:group_member, :developer, user: developer, group: group, created_at: 3.days.ago)

    sign_in(owner)
  end

  it 'sorts account by default' do
    visit_members_list(sort: nil)

    expect(first_row.text).to include(owner.name)
    expect(second_row.text).to include(developer.name)
    expect(page).to have_css(dropdown_toggle_selector, text: 'Account, ascending')
  end

  it 'sorts by max role ascending' do
    visit_members_list(sort: :access_level_asc)

    expect(first_row.text).to include(developer.name)
    expect(second_row.text).to include(owner.name)
    expect(page).to have_css(dropdown_toggle_selector, text: 'Max role, ascending')
  end

  it 'sorts by max role descending' do
    visit_members_list(sort: :access_level_desc)

    expect(first_row.text).to include(owner.name)
    expect(second_row.text).to include(developer.name)
    expect(page).to have_css(dropdown_toggle_selector, text: 'Max role, descending')
  end

  it 'sorts by access granted ascending' do
    visit_members_list(sort: :last_joined)

    expect(first_row.text).to include(developer.name)
    expect(second_row.text).to include(owner.name)
    expect(page).to have_css(dropdown_toggle_selector, text: 'Access granted, ascending')
  end

  it 'sorts by access granted descending' do
    visit_members_list(sort: :oldest_joined)

    expect(first_row.text).to include(owner.name)
    expect(second_row.text).to include(developer.name)
    expect(page).to have_css(dropdown_toggle_selector, text: 'Access granted, descending')
  end

  it 'sorts by account ascending' do
    visit_members_list(sort: :name_asc)

    expect(first_row.text).to include(owner.name)
    expect(second_row.text).to include(developer.name)
    expect(page).to have_css(dropdown_toggle_selector, text: 'Account, ascending')
  end

  it 'sorts by account descending' do
    visit_members_list(sort: :name_desc)

    expect(first_row.text).to include(developer.name)
    expect(second_row.text).to include(owner.name)
    expect(page).to have_css(dropdown_toggle_selector, text: 'Account, descending')
  end

  it 'sorts by last sign-in ascending', :clean_gitlab_redis_shared_state do
    visit_members_list(sort: :recent_sign_in)

    expect(first_row.text).to include(owner.name)
    expect(second_row.text).to include(developer.name)
    expect(page).to have_css(dropdown_toggle_selector, text: 'Last sign-in, ascending')
  end

  it 'sorts by last sign-in descending', :clean_gitlab_redis_shared_state do
    visit_members_list(sort: :oldest_sign_in)

    expect(first_row.text).to include(developer.name)
    expect(second_row.text).to include(owner.name)
    expect(page).to have_css(dropdown_toggle_selector, text: 'Last sign-in, descending')
  end

  def visit_members_list(sort:)
    visit group_group_members_path(group.to_param, sort: sort)
  end
end
