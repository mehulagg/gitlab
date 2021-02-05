# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BillingPlansHelper do
  describe '#subscription_plan_data_attributes' do
    let(:customer_portal_url) { "#{EE::SUBSCRIPTIONS_URL}/subscriptions" }

    let(:group) { build(:group) }
    let(:plan) do
      OpenStruct.new(id: 'external-paid-plan-hash-code', name: 'Bronze Plan')
    end

    context 'when group and plan with ID present' do
      it 'returns data attributes' do
        add_seats_href = "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/extra_seats"
        upgrade_href = "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/upgrade/#{plan.id}"
        renew_href = "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/renew"
        billable_seats_href = helper.group_seat_usage_path(group)

        expect(helper.subscription_plan_data_attributes(group, plan))
          .to eq(namespace_id: group.id,
                 namespace_name: group.name,
                 is_group: "true",
                 add_seats_href: add_seats_href,
                 plan_upgrade_href: upgrade_href,
                 plan_renew_href: renew_href,
                 customer_portal_url: customer_portal_url,
                 billable_seats_href: billable_seats_href,
                 plan_name: plan.name)
      end
    end

    context 'when group not present' do
      let(:group) { nil }

      it 'returns empty data attributes' do
        expect(helper.subscription_plan_data_attributes(group, plan)).to eq({})
      end
    end

    context 'when plan not present' do
      let(:plan) { nil }

      it 'returns attributes' do
        add_seats_href = "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/extra_seats"
        billable_seats_href = helper.group_seat_usage_path(group)
        renew_href = "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/renew"

        expect(helper.subscription_plan_data_attributes(group, plan))
          .to eq(add_seats_href:  add_seats_href,
                 billable_seats_href: billable_seats_href,
                 customer_portal_url: customer_portal_url,
                 is_group: "true",
                 namespace_id: nil,
                 namespace_name: group.name,
                 plan_renew_href: renew_href,
                 plan_upgrade_href: nil,
                 plan_name: nil)
      end
    end

    context 'when plan with ID not present' do
      let(:plan) { OpenStruct.new(id: nil, name: 'Bronze Plan') }

      it 'returns data attributes without upgrade href' do
        add_seats_href = "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/extra_seats"
        renew_href = "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/renew"
        billable_seats_href = helper.group_seat_usage_path(group)

        expect(helper.subscription_plan_data_attributes(group, plan))
          .to eq(namespace_id: group.id,
                 namespace_name: group.name,
                 is_group: "true",
                 customer_portal_url: customer_portal_url,
                 billable_seats_href: billable_seats_href,
                 add_seats_href: add_seats_href,
                 plan_renew_href: renew_href,
                 plan_upgrade_href: nil,
                 plan_name: plan.name)
      end
    end

    context 'when namespace is passed in' do
      it 'returns false for is_group' do
        namespace = build(:namespace)

        result = helper.subscription_plan_data_attributes(namespace, plan)

        expect(result).to include(is_group: "false")
      end
    end
  end

  describe '#use_new_purchase_flow?' do
    where type: ['Group', nil],
      plan: Plan.all_plans,
      trial_active: [true, false]

    with_them do
      let_it_be(:user) { create(:user) }
      let(:namespace) do
        create :namespace, type: type,
          gitlab_subscription: create(:gitlab_subscription, hosted_plan: create("#{plan}_plan".to_sym))
      end

      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(namespace).to receive(:trial_active?).and_return(trial_active)
      end

      subject { helper.use_new_purchase_flow?(namespace) }

      it do
        result = type == 'Group' && (plan == Plan::FREE || trial_active)

        is_expected.to be(result)
      end
    end

    context 'when the group is on a plan eligible for the new purchase flow' do
      let(:namespace) do
        create(
          :namespace,
          type: Group,
          gitlab_subscription: create(:gitlab_subscription, hosted_plan: create(:free_plan))
        )
      end

      before do
        allow(helper).to receive(:current_user).and_return(user)
      end

      context 'when the user has a last name' do
        let(:user) { build(:user, last_name: 'Lastname') }

        it 'returns true' do
          expect(helper.use_new_purchase_flow?(namespace)).to eq true
        end
      end

      context 'when the user does not have a last name' do
        let(:user) { build(:user, last_name: nil, name: 'Firstname') }

        it 'returns false' do
          expect(helper.use_new_purchase_flow?(namespace)).to eq false
        end
      end
    end
  end

  describe '#upgrade_offer_type' do
    using RSpec::Parameterized::TableSyntax

    let(:plan) { OpenStruct.new({ id: '123456789' }) }

    context 'when plan has a valid property' do
      where(:plan_name, :for_free, :plan_id, :result) do
        Plan::BRONZE | true  | '123456789'  | :upgrade_for_free
        Plan::BRONZE | true  | '987654321'  | :no_offer
        Plan::BRONZE | true  | nil          | :no_offer
        Plan::BRONZE | false | '123456789'  | :upgrade_for_offer
        Plan::BRONZE | false | nil          | :no_offer
        Plan::BRONZE | nil   | nil          | :no_offer
        Plan::SILVER | nil   | nil          | :no_offer
        nil          | true  | nil          | :no_offer
      end

      with_them do
        let(:namespace) do
          OpenStruct.new(
            {
              actual_plan_name: plan_name,
              id: '000000000'
            }
          )
        end

        before do
          allow_next_instance_of(GitlabSubscriptions::PlanUpgradeService) do |instance|
            expect(instance).to receive(:execute).once.and_return({
             upgrade_for_free: for_free,
             upgrade_plan_id: plan_id
            })
          end
        end

        subject { helper.upgrade_offer_type(namespace, plan) }

        it { is_expected.to eq(result) }
      end
    end
  end

  describe '#has_upgrade?' do
    using RSpec::Parameterized::TableSyntax

    where(:offer_type, :result) do
      :no_offer          | false
      :upgrade_for_free  | true
      :upgrade_for_offer | true
    end

    with_them do
      subject { helper.has_upgrade?(offer_type) }

      it { is_expected.to eq(result) }
    end
  end

  describe '#show_contact_sales_button?' do
    using RSpec::Parameterized::TableSyntax

    where(:experiment_enabled, :link_action, :upgrade_offer, :result) do
      true  | 'upgrade'     | :no_offer           | true
      true  | 'upgrade'     | :upgrade_for_offer  | true
      true  | 'no_upgrade'  | :no_offer           | false
      true  | 'no_upgrade'  | :upgrade_for_offer  | false
      false | 'upgrade'     | :no_offer           | false
      false | 'upgrade'     | :upgrade_for_offer  | true
      false | 'no_upgrade'  | :no_offer           | false
      false | 'no_upgrade'  | :upgrade_for_offer  | false
    end

    with_them do
      before do
        allow(helper).to receive(:experiment_enabled?).with(:contact_sales_btn_in_app).and_return(experiment_enabled)
      end

      subject { helper.show_contact_sales_button?(link_action, upgrade_offer) }

      it { is_expected.to eq(result) }
    end
  end

  describe '#show_upgrade_button?' do
    using RSpec::Parameterized::TableSyntax

    where(:link_action, :upgrade_offer, :result) do
      'upgrade'     | :no_offer          | true
      'upgrade'     | :upgrade_for_free  | true
      'upgrade'     | :upgrade_for_offer | false
      'no_upgrade'  | :no_offer          | false
      'no_upgrade'  | :upgrade_for_free  | false
      'no_upgrade'  | :upgrade_for_offer | false
    end

    with_them do
      subject { helper.show_upgrade_button?(link_action, upgrade_offer) }

      it { is_expected.to eq(result) }
    end
  end

  describe '#experiment_tracking_data_for_button_click' do
    let(:button_label) { 'some_label' }
    let(:experiment_enabled) { false }

    subject { helper.experiment_tracking_data_for_button_click(button_label) }

    before do
      stub_experiment(contact_sales_btn_in_app: experiment_enabled)
    end

    context 'when the experiment is not enabled' do
      it { is_expected.to eq({}) }
    end

    context 'when the experiment is enabled' do
      let(:experiment_enabled) { true }

      before do
        allow(helper).to receive(:experiment_tracking_category_and_group).with(:contact_sales_btn_in_app).and_return("Category:control_group")
      end

      it 'returns a hash to be used as data-attributes in a view' do
        is_expected.to eq({
          track: {
            event: 'click_button',
            label: button_label,
            property: 'Category:control_group'
          }
        })
      end
    end
  end

  describe '#plan_feature_list' do
    let(:plan) do
      Hashie::Mash.new(features: (1..3).map { |i| { title: "feat 0#{i}", highlight: i.even? } })
    end

    it 'returns features list sorted by highlight attribute' do
      expect(helper.plan_feature_list(plan)).to eq([{ 'title' => 'feat 02', 'highlight' => true },
                                                    { 'title' => 'feat 01', 'highlight' => false },
                                                    { 'title' => 'feat 03', 'highlight' => false }])
    end
  end

  describe '#seats_data_last_update_info' do
    before do
      allow(UpdateMaxSeatsUsedForGitlabComSubscriptionsWorker).to receive(:last_enqueue_time).and_return(enqueue_time)
    end

    context 'when last_enqueue_time from the worker is known' do
      let(:enqueue_time) { Time.current }

      it 'shows the last enqueue time' do
        expect(helper.seats_data_last_update_info).to match("as of #{enqueue_time}")
      end
    end

    context 'when last_enqueue_time from the worker is unknown' do
      let(:enqueue_time) { nil }

      it 'shows default message' do
        expect(helper.seats_data_last_update_info).to match('is updated every day at 12:00pm UTC')
      end
    end
  end

  describe "#plan_purchase_or_upgrade_url" do
    let(:plan) { double('Plan') }

    it 'is upgradable' do
      group = double('Group', upgradable?: true)

      expect(helper).to receive(:plan_upgrade_url)

      helper.plan_purchase_or_upgrade_url(group, plan)
    end

    it 'is purchasable' do
      group = double('Group', upgradable?: false)

      expect(helper).to receive(:plan_purchase_url)

      helper.plan_purchase_or_upgrade_url(group, plan)
    end
  end

  describe '#upgrade_button_css_classe' do
    using RSpec::Parameterized::TableSyntax

    let(:plan) { double('Plan', deprecated?: false) }

    it 'returns button-related classes only' do
      expect(helper.upgrade_button_css_classes(nil, plan, false)).to eq('btn btn-success gl-button')
    end

    where(:is_current_plan, :trial_active, :result) do
      false | false | 'btn btn-success gl-button'
      false | true  | 'btn btn-success gl-button'
      true  | true  | 'btn btn-success gl-button'
      true  | false | 'btn btn-success gl-button disabled'
      false | false | 'btn btn-success gl-button'
    end

    with_them do
      let(:namespace) { OpenStruct.new(trial_active: trial_active) }

      subject { helper.upgrade_button_css_classes(namespace, plan, is_current_plan) }

      it { is_expected.to include(result) }
    end

    context 'when plan is deprecated' do
      let(:deprecated_plan) { double('Plan', deprecated?: true) }

      it 'returns invisible class' do
        expect(helper.upgrade_button_css_classes(nil, deprecated_plan, false)).to include('invisible')
      end
    end
  end

  describe '#billing_available_plans' do
    let(:plan) { double('Plan', deprecated?: false, code: 'silver', hide_deprecated_card?: false) }
    let(:deprecated_plan) { double('Plan', deprecated?: true, code: 'bronze', hide_deprecated_card?: false) }
    let(:plans_data) { [plan, deprecated_plan] }

    context 'when namespace is not on a plan' do
      it 'returns plans without deprecated' do
        expect(helper.billing_available_plans(plans_data, nil)).to eq([plan])
      end
    end

    context 'when namespace is on an active plan' do
      let(:current_plan) { OpenStruct.new(code: 'silver') }

      it 'returns plans without deprecated' do
        expect(helper.billing_available_plans(plans_data, nil)).to eq([plan])
      end
    end

    context 'when namespace is on a deprecated plan' do
      let(:current_plan) { OpenStruct.new(code: 'bronze') }

      it 'returns plans with a deprecated plan' do
        expect(helper.billing_available_plans(plans_data, current_plan)).to eq(plans_data)
      end
    end

    context 'when namespace is on a deprecated plan that has hide_deprecated_card set to true' do
      let(:current_plan) { OpenStruct.new(code: 'bronze') }
      let(:deprecated_plan) { double('Plan', deprecated?: true, code: 'bronze', hide_deprecated_card?: true) }

      it 'returns plans without the deprecated plan' do
        expect(helper.billing_available_plans(plans_data, current_plan)).to eq([plan])
      end
    end

    context 'when namespace is on a plan that has hide_deprecated_card set to true, but deprecated? is false' do
      let(:current_plan) { OpenStruct.new(code: 'silver') }
      let(:plan) { double('Plan', deprecated?: false, code: 'silver', hide_deprecated_card?: true) }

      it 'returns plans with the deprecated plan' do
        expect(helper.billing_available_plans(plans_data, current_plan)).to eq([plan])
      end
    end
  end

  describe '#subscription_plan_info' do
    it 'returns the current plan' do
      other_plan = Hashie::Mash.new(code: 'bronze')
      current_plan = Hashie::Mash.new(code: 'gold')

      expect(helper.subscription_plan_info([other_plan, current_plan], 'gold')).to eq(current_plan)
    end

    it 'returns nil if no plan matches the code' do
      plan_a = Hashie::Mash.new(code: 'bronze')
      plan_b = Hashie::Mash.new(code: 'gold')

      expect(helper.subscription_plan_info([plan_a, plan_b], 'default')).to be_nil
    end

    it 'breaks a tie with the current_subscription_plan attribute if multiple plans have the same code' do
      other_plan = Hashie::Mash.new(current_subscription_plan: false, code: 'silver')
      current_plan = Hashie::Mash.new(current_subscription_plan: true, code: 'silver')

      expect(helper.subscription_plan_info([other_plan, current_plan], 'silver')).to eq(current_plan)
    end

    it 'returns nil if no plan matches the code even if current_subscription_plan is true' do
      other_plan = Hashie::Mash.new(current_subscription_plan: false, code: 'free')
      current_plan = Hashie::Mash.new(current_subscription_plan: true, code: 'bronze')

      expect(helper.subscription_plan_info([other_plan, current_plan], 'default')).to be_nil
    end

    it 'returns the plan matching the plan code even if current_subscription_plan is false' do
      other_plan = Hashie::Mash.new(current_subscription_plan: false, code: 'bronze')
      current_plan = Hashie::Mash.new(current_subscription_plan: false, code: 'silver')

      expect(helper.subscription_plan_info([other_plan, current_plan], 'silver')).to eq(current_plan)
    end
  end
end
