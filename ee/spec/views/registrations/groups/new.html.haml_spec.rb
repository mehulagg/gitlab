# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'registrations/groups/new' do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:trial_onboarding_flow) { false }
  let_it_be(:show_trial_during_signup) { true }

  before do
    assign(:group, group)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:in_trial_onboarding_flow?).and_return(trial_onboarding_flow)
    allow(view).to receive(:show_trial_during_signup?).and_return(show_trial_during_signup)

    render
  end

  subject { rendered }

  it 'shows trial form and hides invite members' do
    is_expected.to have_content('Company name')
    is_expected.not_to have_selector('.js-invite-members')
  end

  it 'shows the progress bar' do
    expect(rendered).to have_selector('#progress-bar')
  end

  it 'shows the trial during signup form' do
    expect(rendered).to have_content('GitLab Ultimate trial (optional)')
  end

  context 'in trial onboarding' do
    let_it_be(:trial_onboarding_flow) { true }

    it 'hides trial form' do
      is_expected.not_to have_content('Company name')
    end

    it 'hides the progress bar' do
      expect(rendered).not_to have_selector('#progress-bar')
    end
  end

  context 'not showing trial during signup' do
    let_it_be(:show_trial_during_signup) { false }

    it 'shows the trial during signup form' do
      expect(rendered).not_to have_content('GitLab Ultimate trial (optional)')
    end
  end
end
