# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PaidFeatureCalloutHelper do
  describe '#run_highlight_paid_features_during_active_trial_experiment', :experiment do
    let_it_be(:group) { create(:group) }
    let_it_be(:user) { create(:user) }
    let_it_be(:candidate_block) { proc { 'in candidate' } }

    let(:trials_available) { true }
    let(:user_can_admin_group) { true }
    let(:group_has_active_trial) { true }

    before do
      stub_application_setting(check_namespace_plan: trials_available)
      stub_experiments(highlight_paid_features_during_active_trial: variant)
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:can?).with(user, :admin_namespace, group).and_return(user_can_admin_group)
      allow(group).to receive(:trial_active?).and_return(group_has_active_trial)
    end

    subject { helper.run_highlight_paid_features_during_active_trial_experiment(group, &candidate_block).run }

    context 'when the user is in the candidate' do
      let(:variant) { :candidate }

      it { is_expected.to eq('in candidate') }
    end

    shared_examples 'user receives control experience' do
      it { is_expected.to be_nil }
    end

    context 'when the user is in the control' do
      let(:variant) { :control }

      include_examples 'user receives control experience'
    end

    context 'when the user would be in the candidate' do
      let(:variant) { :candidate }

      context 'but trials are not available' do
        let(:trials_available) { false }

        include_examples 'user receives control experience'
      end

      context 'but the group is not in an active trial' do
        let(:group_has_active_trial) { false }

        include_examples 'user receives control experience'
      end

      context 'but the user is not an admin of the group' do
        let(:user_can_admin_group) { false }

        include_examples 'user receives control experience'
      end
    end
  end
end
