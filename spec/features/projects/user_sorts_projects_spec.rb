# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User sorts projects and order persists' do
  include CookieHelper

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:group_member) { create(:group_member, :maintainer, user: user, group: group) }
  let_it_be(:project) { create(:project, :public, group: group) }

  it 'from explore projects' do
    sign_in(user)
    visit(explore_projects_path)
    find('#sort-projects-dropdown').click

    first(:link, 'Last updated').click

    visit(dashboard_projects_path)

    expect(find('.dropdown-menu a.is-active', text: 'Last updated')).to have_content('Last updated')

    visit(explore_projects_path)

    expect(find('.dropdown-menu a.is-active', text: 'Last updated')).to have_content('Last updated')

    visit(group_canonical_path(group))

    expect(find('.dropdown-menu a.is-active', text: 'Last updated')).to have_content('Last updated')

    visit(details_group_path(group))

    expect(find('.dropdown-menu a.is-active', text: 'Last updated')).to have_content('Last updated')
  end

  it 'from dashboard projects' do
    sign_in(user)
    visit(dashboard_projects_path)
    find('#sort-projects-dropdown').click

    first(:link, 'Name').click

    visit(dashboard_projects_path)

    expect(find('.dropdown-menu a.is-active', text: 'Name')).to have_content('Name')

    visit(explore_projects_path)

    expect(find('.dropdown-menu a.is-active', text: 'Name')).to have_content('Name')

    visit(group_canonical_path(group))

    expect(find('.dropdown-menu a.is-active', text: 'Name')).to have_content('Name')

    visit(details_group_path(group))

    expect(find('.dropdown-menu a.is-active', text: 'Name')).to have_content('Name')
  end

  it 'from group homepage' do
    sign_in(user)
    visit(group_canonical_path(group))
    find('button.dropdown-menu-toggle').click

    first(:link, 'Last created').click

    visit(dashboard_projects_path)

    expect(find('.dropdown-menu a.is-active', text: 'Created date')).to have_content('Created date')

    visit(explore_projects_path)

    expect(find('.dropdown-menu a.is-active', text: 'Created date')).to have_content('Created date')

    visit(group_canonical_path(group))

    expect(find('.dropdown-menu a.is-active', text: 'Last created')).to have_content('Last created')

    visit(details_group_path(group))

    expect(find('.dropdown-menu a.is-active', text: 'Last created')).to have_content('Last created')
  end

  it 'from group details' do
    sign_in(user)
    visit(details_group_path(group))
    find('button.dropdown-menu-toggle').click

    first(:link, 'Most stars').click

    visit(dashboard_projects_path)

    expect(find('.dropdown-menu a.is-active', text: 'Stars')).to have_content('Stars')

    visit(explore_projects_path)

    expect(find('.dropdown-menu a.is-active', text: 'Stars')).to have_content('Stars')

    visit(group_canonical_path(group))

    expect(find('.dropdown-menu a.is-active', text: 'Most stars')).to have_content('Most stars')

    visit(details_group_path(group))

    expect(find('.dropdown-menu a.is-active', text: 'Most stars')).to have_content('Most stars')
  end
end
