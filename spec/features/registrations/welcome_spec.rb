# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Welcome screen' do
  let_it_be(:user) { create(:user, :unconfirmed) }
  let_it_be(:group) { create(:group) }

  before do
    group.add_owner(user)
    gitlab_sign_in(user)
  end

  it 'shows the email opt in' do
    visit users_sign_up_welcome_path

    select 'Software Developer', from: 'user_role'
    check 'user_email_opted_in'
    click_button 'Get started!'

    expect(user.reload.email_opted_in).to eq(true)
  end

  it 'allows specifying other for the jobs_to_be_done experiment', :js, :experiment do
    stub_experiments(jobs_to_be_done: :candidate)
    visit users_sign_up_welcome_path

    expect(page).not_to have_content('Why are you signing up? (Optional)')

    select 'A different reason', from: 'jobs_to_be_done'

    expect(page).to have_content('Why are you signing up? (Optional)')

    fill_in 'jobs_to_be_done_other', with: 'My reason'
  end
end
