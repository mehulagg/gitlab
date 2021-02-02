# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User sees new onboarding flow', :js do
  before do
    stub_const('Gitlab::QueryLimiting::Transaction::THRESHOLD', 200)
    stub_experiment_for_subject(onboarding_issues: true)
    allow(Gitlab).to receive(:com?).and_return(true)
    gitlab_sign_in(:user)
    visit users_sign_up_welcome_path
  end

  it 'shows the expected pages' do
    expect(page).to have_content('Welcome to GitLab')
    expect(page).to have_content('Your profile Your GitLab group Your first project')
    expect(page).to have_css('li.current', text: 'Your profile')

    choose 'Just me'
    click_on 'Continue'

    expect(page).to have_content('Create your group')
    expect(page).to have_content('Your profile Your GitLab group Your first project')
    expect(page).to have_css('li.current', text: 'Your GitLab group')

    fill_in 'group_name', with: 'test'

    expect(page).to have_field('group_path', with: 'test')

    click_on 'Create group'

    expect(page).to have_content('Create/import your first project')
    expect(page).to have_content('Your profile Your GitLab group Your first project')
    expect(page).to have_css('li.current', text: 'Your first project')

    fill_in 'project_name', with: 'test'

    expect(page).to have_field('project_path', with: 'test')

    click_on 'Create project'

    expect(page).to have_content('Welcome to the guided GitLab tour')

    Sidekiq::Worker.drain_all

    click_on 'Show me the basics'

    expect(page).to have_content('Learn GitLab')
    expect(page).to have_css('.selectable', text: 'Label = ~Novice')

    visit group_path('test')

    expect(page).to have_css('.popover', text: 'Here are all your projects in your group, including the one you just created. To start, let’s take a look at your personalized learning project which will help you learn about GitLab at your own pace. 1 / 2')

    click_on 'Learn GitLab'

    expect(page).to have_content('We prepared tutorials to help you set up GitLab in a way to support your complete software development life cycle.')
    expect(page).to have_css('.popover', text: 'Go to Issues > Boards to access your personalized learning issue board. 2 / 2')

    page.find('.nav-item-name', text: 'Issues').click

    expect(page).to have_css('.popover', text: 'Go to Issues > Boards to access your personalized learning issue board. 2 / 2')
  end
end
