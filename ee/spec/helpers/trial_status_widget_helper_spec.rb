# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TrialStatusWidgetHelper do
  describe 'data attributes for mounting Vue components' do
    let(:trial_length) { 30 } # days
    let(:today_for_specs) { Date.parse('2021-01-15') }
    let(:trial_days_remaining) { 18 }
    let(:trial_end_date) { Date.current.advance(days: trial_days_remaining) }
    let(:trial_percentage_complete) { (trial_length - trial_days_remaining) * 100 / trial_length }
    let(:subscription) { instance_double(GitlabSubscription, plan_title: 'Ultimate') }

    let(:group) do
      instance_double(Group,
        id: 123,
        name: 'Pants Group',
        to_param: 'pants-group',
        gitlab_subscription: subscription,
        trial_days_remaining: trial_days_remaining,
        trial_ends_on: trial_end_date,
        trial_percentage_complete: trial_percentage_complete
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
      travel_to today_for_specs
    end

    describe '#trial_status_popover_data_attrs' do
      let(:popover_shared_expected_attrs) do
        shared_expected_attrs.merge(
          group_name: group.name,
          purchase_href: new_subscriptions_path(namespace_id: group.id, plan_id: described_class::ZUORA_ULTIMATE_PLAN_ID),
          target_id: shared_expected_attrs[:container_id],
          start_initially_shown: false,
          trial_end_date: trial_end_date
        )
      end

      subject(:data_attrs) { helper.trial_status_popover_data_attrs(group) }

      shared_examples 'returned data attributes' do |shown: false|
        it 'returns the correct set of data attributes' do
          expect(data_attrs).to match(
            popover_shared_expected_attrs.merge(
              start_initially_shown: shown
            )
          )
        end
      end

      context 'when more than 14 days remain' do
        where trial_days_remaining: [15, 22, 30]

        with_them do
          include_examples 'returned data attributes'
        end
      end

      context 'when between 7 & 14 days remain' do
        where trial_days_remaining: [7, 10, 14]

        with_them do
          include_examples 'returned data attributes', shown: true
        end
      end

      context 'when between 4 & 6 days remain' do
        where trial_days_remaining: [4, 5, 6]

        with_them do
          include_examples 'returned data attributes'
        end
      end

      context 'when between 0 & 3 days remain' do
        where trial_days_remaining: [0, 1, 3]

        with_them do
          include_examples 'returned data attributes', shown: true
        end
      end

      context 'when fewer than 0 days remain' do
        where trial_days_remaining: [-1, -5, -12]

        with_them do
          include_examples 'returned data attributes'
        end
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
            days_remaining: trial_days_remaining,
            nav_icon_image_path: '/image-path/for-file.svg',
            percentage_complete: trial_percentage_complete
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
