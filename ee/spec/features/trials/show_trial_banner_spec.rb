# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Show trial banner', :js do
  include StubRequests
  include SubscriptionPortalHelpers

  let!(:user) { create(:user) }
  let!(:group) { create(:group) }
  let!(:ultimate_plan) { create(:ultimate_plan) }

  before do
    stub_application_setting(check_namespace_plan: true)
    allow(Gitlab).to receive(:com?).and_return(true).at_least(:once)
    stub_billing_plans(namespace_id)

    group.add_owner(user)
    create(:gitlab_subscription, namespace: user.namespace, hosted_plan: ultimate_plan, trial: true, trial_ends_on: Date.current + 1.month)
    create(:gitlab_subscription, namespace: group, hosted_plan: ultimate_plan, trial: true, trial_ends_on: Date.current + 1.month)

    gitlab_sign_in(user)
  end

  context "when user's trial is active" do
    let(:namespace_id) { user.namespace_id }

    it 'renders congratulations banner for user in profile billing page' do
      visit profile_billings_path + '?trial=true'

      expect(page).to have_content('Congratulations, your free trial is activated.')
    end
  end

  context "when group's trial is active" do
    let(:namespace_id) { group.id }

    it 'renders congratulations banner for group in group details page' do
      visit group_path(group, trial: true)

      expect(find('.user-callout').text).to have_content('Congratulations, your free trial is activated.')
    end

    it 'does not render congratulations banner for group in group billing page' do
      visit group_billings_path(group, trial: true)

      expect(page).not_to have_content('Congratulations, your free trial is activated.')
    end
  end
end
