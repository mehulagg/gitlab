# frozen_string_literal: true

require 'spec_helper'

describe SubscriptionsHelper do
  let_it_be(:raw_plan_data) do
    [
      {
        "name" => "Free Plan",
        "free" => true
      },
      {
        "id" => "bronze_id",
        "name" => "Bronze Plan",
        "free" => false,
        "code" => "bronze",
        "price_per_year" => 48.0
      }
    ]
  end

  before do
    allow(helper).to receive(:params).and_return(plan_id: 'bronze_id')
    allow_any_instance_of(FetchSubscriptionPlansService).to receive(:execute).and_return(raw_plan_data)
  end

  describe '#subscription_data' do
    let_it_be(:user) { create(:user, setup_for_company: nil, name: 'First Last') }
    let_it_be(:group) { create(:group, name: 'My Namespace', id: 11) }

    before do
      allow(helper).to receive(:current_user).and_return(user)
      group.add_owner(user)
    end

    subject { helper.subscription_data }

    it { is_expected.to include(setup_for_company: 'false') }
    it { is_expected.to include(full_name: 'First Last') }
    it { is_expected.to include(plan_data: '[{"id":"bronze_id","code":"bronze","price_per_year":48.0}]') }
    it { is_expected.to include(plan_id: 'bronze_id') }
    it { is_expected.to include(new_user: 'false') }
    it { is_expected.to include(group_data: '[{"id":11,"name":"My Namespace","users":1}]') }

    context 'with new_user param in the URL' do
      before do
        allow(helper).to receive(:params).and_return(plan_id: 'bronze_id', new_user: 'true')
      end

      it { is_expected.to include(new_user: 'true') }
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
