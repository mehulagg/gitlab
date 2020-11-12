# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Welcome screen', :js do
  let_it_be(:user) { create(:user) }

  let(:in_invitation_flow) { false }
  let(:in_subscription_flow) { false }
  let(:in_trial_flow) { false }
  let(:part_of_onboarding_issues_experiment) { false }

  describe 'on GitLab.com' do
    before do
      allow(Gitlab).to receive(:com?).and_return(true)
      gitlab_sign_in(user)
      allow_any_instance_of(EE::WelcomeHelper).to receive(:in_invitation_flow?).and_return(in_invitation_flow)
      allow_any_instance_of(EE::WelcomeHelper).to receive(:in_subscription_flow?).and_return(in_subscription_flow)
      allow_any_instance_of(EE::WelcomeHelper).to receive(:in_trial_flow?).and_return(in_trial_flow)
      stub_experiment_for_user(onboarding_issues: part_of_onboarding_issues_experiment)

      visit users_sign_up_welcome_path
    end

    it 'shows the welcome page without a progress bar' do
      expect(page).to have_content('Welcome to GitLab')
      expect(page).not_to have_content('Your profile')
    end

    context 'when in the subscription flow' do
      let(:in_subscription_flow) { true }

      it 'shows the progress bar with the correct steps' do
        expect(page).to have_content('Your profile Checkout Your GitLab group')
      end
    end

    context 'when part of the onboarding issues experiment' do
      let(:part_of_onboarding_issues_experiment) { true }

      it 'shows the progress bar with the correct steps' do
        expect(page).to have_content('Your profile Your GitLab group Your first project')
      end

      context 'when in the invitation flow' do
        let(:in_invitation_flow) { true }

        it 'does not show the progress bar' do
          expect(page).not_to have_content('Your profile')
        end
      end

      context 'when in the trial flow' do
        let(:in_trial_flow) { true }

        it 'does not show the progress bar' do
          expect(page).not_to have_content('Your profile')
        end
      end
    end
  end
end
