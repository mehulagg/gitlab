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

  describe 'data attributes for mounting Vue components' do
    let(:subscription) { instance_double(GitlabSubscription, plan_title: 'Ultimate') }

    let(:group) do
      instance_double(Group,
        id: 123,
        name: 'Pants Group',
        to_param: 'pants-group',
        gitlab_subscription: subscription,
        trial_days_remaining: 12,
        trial_ends_on: Date.current.advance(days: 18),
        trial_percentage_complete: 40
      )
    end

    let(:shared_expected_attrs) do
      {
        container_id: 'trial-status-sidebar-widget',
        plan_name: 'Ultimate',
        plans_href: '/groups/pants-group/-/billings'
      }
    end

    before do
      travel_to Date.parse('2021-01-12')
    end

    describe '#trial_status_popover_data_attrs' do
      subject(:data_attrs) { helper.trial_status_popover_data_attrs(group) }

      it 'returns the needed data attributes for mounting the Vue component' do
        expect(data_attrs).to match(
          shared_expected_attrs.merge(
            group_name: 'Pants Group',
            purchase_href: '/-/subscriptions/new?namespace_id=123&plan_id=2c92a0fc5a83f01d015aa6db83c45aac',
            target_id: shared_expected_attrs[:container_id],
            trial_end_date: Date.parse('2021-01-30')
          )
        )
      end
    end

    describe '#trial_status_widget_data_attrs' do
      before do
        allow(helper).to receive(:image_path).and_return('/image-path/for-file.svg')
      end

      subject(:data_attrs) { helper.trial_status_widget_data_attrs(group) }

      it 'returns the needed data attributes for mounting the Vue component' do
        expect(data_attrs).to match(
          shared_expected_attrs.merge(
            days_remaining: 12,
            nav_icon_image_path: '/image-path/for-file.svg',
            percentage_complete: 40
          )
        )
      end
    end
  end
end
