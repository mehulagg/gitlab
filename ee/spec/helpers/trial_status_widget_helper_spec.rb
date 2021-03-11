# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TrialStatusWidgetHelper do
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

  describe '#show_trial_status_widget?' do
    let(:user) { instance_double(User) }
    let(:group) { instance_double(Group, trial_active?: trial_active) }

    before do
      stub_application_setting(check_namespace_plan: trials_available)
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:can?).and_call_original
      allow(helper).to receive(:can?).with(user, :admin_namespace, group).and_return(user_can_admin_group)
    end

    subject { helper.show_trial_status_widget?(group) }

    where(
      trials_available: [true, false],
      trial_active: [true, false],
      user_can_admin_group: [true, false]
    )

    with_them do
      it { is_expected.to eq(trials_available && trial_active && user_can_admin_group) }
    end
  end
end
