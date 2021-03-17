# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TrialStatusWidgetHelper do
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
        days_remaining: 12,
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
            nav_icon_image_path: '/image-path/for-file.svg',
            percentage_complete: 40
          )
        )
      end
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
