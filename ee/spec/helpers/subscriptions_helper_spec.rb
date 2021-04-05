# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SubscriptionsHelper do
  include SubscriptionPortalHelpers

  using RSpec::Parameterized::TableSyntax

  let_it_be(:free_plan) do
    { "name" => "Free Plan", "free" => true, "code" => "free" }
  end

  let(:bronze_plan) do
    {
      "id" => "bronze_id",
      "name" => "Bronze Plan",
      "free" => false,
      "code" => "bronze",
      "price_per_year" => 48.0
    }
  end

  let(:raw_plan_data) do
    [free_plan, bronze_plan]
  end

  let(:plan_tags) { 'CI_1000_MINUTES_PLAN' }

  before do
    stub_feature_flags(hide_deprecated_billing_plans: false)
    allow(helper).to receive(:params).and_return(plan_id: 'bronze_id', namespace_id: nil)
    allow_next_instance_of(GitlabSubscriptions::FetchSubscriptionPlansService) do |instance|
      allow(instance).to receive(:execute).and_return(raw_plan_data)
    end
    stub_plan_data_request(plan_tags)
  end

  describe '#subscription_data' do
    let_it_be(:user) { create(:user, setup_for_company: nil, name: 'First Last') }
    let_it_be(:group) { create(:group, name: 'My Namespace') }

    before do
      allow(helper).to receive(:params).and_return(plan_id: 'bronze_id', namespace_id: group.id.to_s)
      allow(helper).to receive(:current_user).and_return(user)
      group.add_owner(user)
    end

    subject { helper.subscription_data([group]) }

    it { is_expected.to include(setup_for_company: 'false') }
    it { is_expected.to include(full_name: 'First Last') }
    it { is_expected.to include(available_plans: '[{"id":"bronze_id","code":"bronze","price_per_year":48.0,"name":"Bronze Plan"}]') }
    it { is_expected.to include(ci_minutes_plans: '[{"name":"1000 CI minutes pack","code":"ci_minutes","active":true,"deprecated":false,"free":null,"price_per_month":0.8333333333333334,"price_per_year":10,"features":null,"about_page_href":null,"hide_deprecated_card":false}]') }
    it { is_expected.to include(plan_id: 'bronze_id') }
    it { is_expected.to include(namespace_id: group.id.to_s) }
    it { is_expected.to include(group_data: %Q{[{"id":#{group.id},"name":"My Namespace","users":1}]}) }

    describe 'new_user' do
      where(:referer, :expected_result) do
        'http://example.com/users/sign_up/welcome?foo=bar'             | 'true'
        'http://example.com'                                           | 'false'
        nil                                                            | 'false'
      end

      with_them do
        before do
          allow(helper).to receive(:request).and_return(double(referer: referer))
        end

        it { is_expected.to include(new_user: expected_result) }
      end
    end

    context 'when bronze_plan is deprecated' do
      let(:bronze_plan) do
        {
          "id" => "bronze_id",
          "name" => "Bronze Plan",
          "deprecated" => true,
          "free" => false,
          "code" => "bronze",
          "price_per_year" => 48.0
        }
      end

      it { is_expected.to include(available_plans: '[{"id":"bronze_id","code":"bronze","price_per_year":48.0,"deprecated":true,"name":"Bronze Plan"}]') }
    end

    context 'when ff purchase_deprecated_plans is enabled' do
      before do
        stub_feature_flags(hide_deprecated_billing_plans: true)
      end

      it { is_expected.to include(available_plans: '[{"id":"bronze_id","code":"bronze","price_per_year":48.0,"name":"Bronze Plan"}]') }

      context 'when bronze_plan is deprecated' do
        let(:bronze_plan) do
          {
            "id" => "bronze_id",
            "name" => "Bronze Plan",
            "deprecated" => true,
            "free" => false,
            "code" => "bronze",
            "price_per_year" => 48.0
          }
        end

        it { is_expected.to include(available_plans: '[]') }
      end
    end

    context 'when ff new_route_ci_minutes_purchase is disabled' do
      before do
        stub_feature_flags(new_route_ci_minutes_purchase: false)
      end

      it { is_expected.not_to include(ci_minutes_plans: '[{"name":"1000 CI minutes pack","code":"ci_minutes","active":true,"deprecated":false,"free":null,"price_per_month":0.8333333333333334,"price_per_year":10,"features":null,"about_page_href":null,"hide_deprecated_card":false}]') }
    end
  end

  describe '#plan_title' do
    subject { helper.plan_title }

    it { is_expected.to eq('Bronze') }

    context 'no plan_id URL parameter present' do
      before do
        allow(helper).to receive(:params).and_return({})
      end

      it { is_expected.to eq(nil) }
    end

    context 'a non-existing plan_id URL parameter present' do
      before do
        allow(helper).to receive(:params).and_return(plan_id: 'xxx')
      end

      it { is_expected.to eq(nil) }
    end
  end
end
