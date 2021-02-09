# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TrialStatusWidgetHelper do
  describe '#show_trial_status_widget?' do
    let_it_be(:user) { create(:user) }

    let(:trials_available) { true }
    let(:experiment_enabled) { true }
    let(:trial_active) { true }
    let(:user_can_admin_group) { true }
    let(:group) { instance_double(Group, trial_active?: trial_active) }

    before do
      # current_user
      allow(helper).to receive(:current_user).and_return(user)

      # billing_plans_and_trials_available?
      stub_application_setting(check_namespace_plan: trials_available)

      # trial_status_widget_experiment_enabled?(group)
      allow(helper).to receive(:experiment_enabled?).with(:show_trial_status_in_sidebar, subject: group).and_return(experiment_enabled)

      # user_can_administer_group?(group)
      allow(helper).to receive(:can?).and_call_original
      allow(helper).to receive(:can?).with(user, :admin_namespace, group).and_return(user_can_admin_group)
    end

    subject { helper.show_trial_status_widget?(group) }

    context 'when all requirements are met for the widget to be shown' do
      it { is_expected.to be_truthy }
    end

    context 'when the app is not configured for billing plans & trials' do
      let(:trials_available) { false }

      it { is_expected.to be_falsey }
    end

    context 'when the experiment is not active or not enabled for the group' do
      let(:experiment_enabled) { false }

      it { is_expected.to be_falsey }
    end

    context 'when the group is not in an active trial' do
      let(:trial_active) { false }

      it { is_expected.to be_falsey }
    end

    context 'when the user is not an admin/owner of the group' do
      let(:user_can_admin_group) { false }

      it { is_expected.to be_falsey }
    end
  end

  describe '#trial_days_remaining_in_words' do
    let_it_be(:group) { build(:group) }
    let!(:subscription) { build(:gitlab_subscription, :active_trial, namespace: group) }

    subject { helper.trial_days_remaining_in_words(group) }

    context 'when there are 0 days remaining' do
      before do
        subscription.trial_ends_on = Date.current
      end

      it { is_expected.to eq('Gold Trial – 0 days left') }
    end

    context 'when there is 1 day remaining' do
      before do
        subscription.trial_ends_on = Date.current.advance(days: 1)
      end

      it { is_expected.to eq('Gold Trial – 1 day left') }
    end

    context 'when there are 2+ days remaining' do
      before do
        subscription.trial_ends_on = Date.current.advance(days: 13)
      end

      it { is_expected.to eq('Gold Trial – 13 days left') }
    end
  end
end
