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

  describe '#plan_title_for_group' do
    using RSpec::Parameterized::TableSyntax

    let_it_be(:group) { create(:group) }

    subject { helper.plan_title_for_group(group) }

    where(:plan, :title) do
      :bronze   | 'Bronze'
      :silver   | 'Silver'
      :gold     | 'Gold'
      :premium  | 'Premium'
      :ultimate | 'Ultimate'
    end

    with_them do
      let!(:subscription) { build(:gitlab_subscription, plan, namespace: group) }

      it { is_expected.to eq(title) }
    end
  end
end
