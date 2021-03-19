# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'registrations/groups/new' do
  let_it_be(:user) { create(:user) }
  let_it_be(:trial_during_signup) { false }
  let_it_be(:group) { create(:group) }
  let_it_be(:trial_onboarding_flow) { false }

  before do
    assign(:group, group)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:experiment_enabled?).with(:trial_during_signup).and_return(trial_during_signup)
    allow(view).to receive(:in_trial_onboarding_flow?).and_return(trial_onboarding_flow)

    render
  end

  subject { rendered }

  context 'feature flag trial_during_signup is enabled' do
    let_it_be(:trial_during_signup) { true }

    it 'shows trial form and hides invite members' do
      is_expected.to have_content('Company name')
      is_expected.not_to have_selector('.js-invite-members')
    end

    context 'in trial onboarding' do
      let_it_be(:trial_onboarding_flow) { true }

      it 'hides trial form and shows invite members' do
        is_expected.not_to have_content('Company name')
        is_expected.to have_selector('.js-invite-members')
      end
    end
  end

  context 'feature flag trial_during_signup is disabled' do
    it 'hides trial form and shows invite members' do
      is_expected.not_to have_content('Company name')
      is_expected.to have_selector('.js-invite-members')
    end
  end

  it 'shows the progress bar' do
    expect(rendered).to have_selector('#progress-bar')
  end

  context 'in trial onboarding' do
    let_it_be(:trial_onboarding_flow) { true }

    it 'hides the progress bar' do
      expect(rendered).not_to have_selector('#progress-bar')
    end
  end
end
