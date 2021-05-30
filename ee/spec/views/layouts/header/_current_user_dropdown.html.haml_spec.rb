# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/header/_current_user_dropdown' do
  let_it_be(:user) { create(:user) }

  describe 'Buy Pipeline Minutes link in user dropdown' do
    let(:need_minutes) { true }
    let(:show_notification_dot) { false }
    let(:show_subtext) { false }

    before do
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:show_upgrade_link?).and_return(false)
      allow(view).to receive(:show_buy_pipeline_minutes?).and_return(need_minutes)
      allow(view).to receive(:show_pipeline_minutes_notification_dot?).and_return(show_notification_dot)
      allow(view).to receive(:show_buy_pipeline_with_subtext?).and_return(show_subtext)
      allow(view).to receive(:root_ancestor_namespace).and_return(user.namespace)

      render
    end

    subject { rendered }

    context 'when pipeline minutes need bought without notification dot' do
      it 'has "Buy Pipeline minutes" link with correct data properties', :aggregate_failures do
        expect(subject).to have_selector('[data-track-event="click_buy_ci_minutes"]')
        expect(subject).to have_selector("[data-track-label='#{user.namespace.actual_plan_name}']")
        expect(subject).to have_selector('[data-track-property="user_dropdown"]')
        expect(subject).to have_link('Buy Pipeline minutes')
        expect(subject).not_to have_content('One of your groups is running out')
      end
    end

    context 'when pipeline minutes need bought and there is a notification dot' do
      let(:show_notification_dot) { true }

      it 'has "Buy Pipeline minutes" link with correct text', :aggregate_failures do
        expect(subject).to have_link('Buy Pipeline minutes')
        expect(subject).to have_content('One of your groups is running out')
        expect(subject).to have_selector('.js-follow-link')
        expect(subject).to have_selector("[data-feature-id='#{::Ci::RunnersHelper::BUY_PIPELINE_MINUTES_NOTIFICATION_DOT}']")
        expect(subject).to have_selector("[data-dismiss-endpoint='#{user_callouts_path}']")
      end
    end

    context 'when pipeline minutes need bought and notification dot has been acknowledged' do
      let(:show_subtext) { true }

      it 'has "Buy Pipeline minutes" link with correct text', :aggregate_failures do
        expect(subject).to have_link('Buy Pipeline minutes')
        expect(subject).to have_content('One of your groups is running out')
        expect(subject).not_to have_selector('.js-follow-link')
        expect(subject).not_to have_selector("[data-feature-id='#{::Ci::RunnersHelper::BUY_PIPELINE_MINUTES_NOTIFICATION_DOT}']")
        expect(subject).not_to have_selector("[data-dismiss-endpoint='#{user_callouts_path}']")
      end
    end

    context 'when ci minutes do not need bought' do
      let(:need_minutes) { false }

      it 'has no "Buy Pipeline minutes" link' do
        expect(subject).not_to have_link('Buy Pipeline minutes')
      end
    end
  end

  describe 'Upgrade link in user dropdown' do
    let(:on_upgradeable_plan) { true }

    before do
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:show_buy_pipeline_minutes?).and_return(false)
      allow(view).to receive(:show_upgrade_link?).and_return(on_upgradeable_plan)

      render
    end

    subject { rendered }

    context 'when user is on an upgradeable plan' do
      it 'displays the Upgrade link' do
        expect(subject).to have_link('Upgrade')
      end
    end

    context 'when user is not on an upgradeable plan' do
      let(:on_upgradeable_plan) { false }

      it 'does not display the Upgrade link' do
        expect(subject).not_to have_link('Upgrade')
      end
    end
  end

  context 'pinning test' do
    before do
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:show_upgrade_link?).and_return(true)
      allow(view).to receive(:show_buy_pipeline_minutes?).and_return(true)
      allow(view).to receive(:show_pipeline_minutes_notification_dot?).and_return(true)
      allow(view).to receive(:show_buy_pipeline_with_subtext?).and_return(true)
      allow(view).to receive(:trials_allowed?).and_return(true)
      allow(view).to receive(:root_ancestor_namespace).and_return(user.namespace)
    end

    def clean_str(str)
      str.strip.gsub(/\n{2,}/,"\n")
    end

    it 'matches snapshot' do
      expected = <<-EOF
<ul>
<li class="current-user">
<a class="gl-line-height-20!" data-user="user1" data-testid="user-profile-link" data-qa-selector="user_profile_link" href="/user1"><div class="gl-font-weight-bold">
John Doe2
</div>
@user1
</a></li>
<li class="divider"></li>
<li>
<button class="gl-button btn btn-link menu-item js-set-status-modal-trigger" type="button">
Set status
</button>
</li>
<li>
<a class="trial-link" href="/-/trial_registrations/new?glm_content=top-right-dropdown&amp;glm_source=gitlab.com">
Start an Ultimate trial
<gl-emoji title="rocket" data-name="rocket" data-unicode-version="6.0">🚀</gl-emoji>
</a>
</li>
<li>
<a data-qa-selector="edit_profile_link" href="/-/profile">Edit profile</a>
</li>
<li>
<a href="/-/profile/preferences">Preferences</a>
</li>
<li class="js-buy-pipeline-minutes-notification-callout" data-dismiss-endpoint="/-/user_callouts" data-feature-id="buy_pipeline_minutes_notification_dot">
<a class="ci-minutes-emoji js-buy-pipeline-minutes-link js-follow-link" data-track-event="click_buy_ci_minutes" data-track-label="default" data-track-property="user_dropdown" href="/-/profile/usage_quotas"><div class="gl-pb-2">
Buy Pipeline minutes
<gl-emoji title="clock face nine oclock" data-name="clock9" data-unicode-version="6.0" aria-hidden="true">🕘</gl-emoji>
</div>
<span class="small gl-pb-3 gl-text-orange-800">
One of your groups is running out
</span>
</a></li>
<li>
<a class="upgrade-plan-link js-upgrade-plan-link" data-track-event="click_upgrade_link" data-track-label="default" data-track-property="user_dropdown" href="https://customers.stg.gitlab.com/plans">Upgrade
<gl-emoji title="rocket" data-name="rocket" data-unicode-version="6.0" aria-hidden="true">🚀</gl-emoji>
</a></li>
<li class="divider d-md-none"></li>
<li class="d-md-none">
<a href="/help">Help</a>
</li>
<li class="d-md-none">
<a href="https://about.gitlab.com/getting-help/">Support</a>
</li>
<li class="d-md-none">
<a target="_blank" class="text-nowrap" rel="noopener noreferrer" data-track-event="click_forum" data-track-property="question_menu" href="https://forum.gitlab.com/">Community forum</a>
</li>
<li class="d-md-none">
<a href="https://about.gitlab.com/submit-feedback">Submit feedback</a>
</li>
<li class="d-md-none">
</li>
<li class="divider"></li>
<li>
<a class="sign-out-link" data-qa-selector="sign_out_link" rel="nofollow" data-method="post" href="/users/sign_out">Sign out</a>
</li>
</ul>
      EOF

      render

      expect(clean_str(rendered)).to eql(clean_str(expected))
    end
  end
end
