# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project fork', :js do
  include ProjectForksHelper

  let(:group) { create(:group) }
  let(:user) { create(:group_member, :maintainer, user: create(:user), group: group ).user }
  let(:project) { create(:project, :public, :repository) }

  before do
    sign_in(user)
  end

  it 'creates fork' do
    visit new_project_fork_path(project)
    submit_form

    expect(page).to have_content 'Forking in progress'
  end

  it 'shows the new forked project on the forks page' do
    visit new_project_fork_path(project)
    submit_form
    wait_for_requests

    visit project_forks_path(project)

    page.within('.js-projects-list-holder') do
      expect(page).to have_content("#{group.name} / #{project.name}")
    end
  end

  it 'shows the filled in info forked project on the forks page' do
    fork_name = 'some-name'
    visit new_project_fork_path(project)
    fill_in('fork-name', with: fork_name, fill_options: { clear: :backspace })
    fill_in('fork-slug', with: fork_name, fill_options: { clear: :backspace })
    submit_form
    wait_for_requests

    visit project_forks_path(project)

    page.within('.js-projects-list-holder') do
      expect(page).to have_content("#{group.name} / #{fork_name}")
    end

  end

  def submit_form
    select(group.name)
    click_button 'Fork project'
  end
end
