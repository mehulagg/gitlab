# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::FilterPurchaseEligibleNamespacesService do
  describe '#execute' do
    let_it_be(:user) { build(:user) }

    context 'when no namespaces are supplied' do
      it 'returns an empty array', :aggregate_failures do
        result = described_class.new(user: user, namespaces: []).execute

        expect(result).to be_success
        expect(result.payload).to eq []
      end
    end

    context 'when no user is supplied' do
      subject(:service) { described_class.new(user: nil, namespaces: [build(:namespace)]) }

      it 'logs and returns an error message', :aggregate_failures do
        expect(Gitlab::ErrorTracking)
          .to receive(:track_and_raise_for_dev_exception)
          .with an_instance_of(ArgumentError)

        result = service.execute

        expect(result).to be_error
        expect(result.message).to eq 'User cannot be nil'
        expect(result.payload).to be_nil
      end
    end

    context 'when the http request fails' do
      subject(:service) { described_class.new(user: user, namespaces: [create(:namespace)]) }

      before do
        allow(Gitlab::SubscriptionPortal::Client).to receive(:filter_purchase_eligible_namespaces).and_return(
          success: false, data: { errors: 'error' }
        )
      end

      it 'returns an error message', :aggregate_failures do
        result = service.execute

        expect(result).to be_error
        expect(result.message).to eq 'Failed to fetch namespaces'
        expect(result.payload).to eq 'error'
      end
    end

    context 'when all the namespaces are eligible' do
      let(:namespace_1) { create(:namespace) }
      let(:namespace_2) { create(:namespace) }

      before do
        allow(Gitlab::SubscriptionPortal::Client).to receive(:filter_purchase_eligible_namespaces).and_return(
          success: true, data: [{ 'id' => namespace_1.id }, { 'id' => namespace_2.id }]
        )
      end

      it 'does not filter any namespaces', :aggregate_failures do
        namespaces = [namespace_1, namespace_2]
        result = described_class.new(user: user, namespaces: namespaces).execute

        expect(result).to be_success
        expect(result.payload).to eq namespaces
      end
    end

    context 'when the user has a namespace ineligible' do
      let(:namespace_1) { create(:namespace) }
      let(:namespace_2) { create(:namespace) }

      before do
        allow(Gitlab::SubscriptionPortal::Client).to receive(:filter_purchase_eligible_namespaces).and_return(
          success: true, data: [{ 'id' => namespace_1.id }]
        )
      end

      it 'is filtered from the results', :aggregate_failures do
        namespaces = [namespace_1, namespace_2]
        result = described_class.new(user: user, namespaces: namespaces).execute

        expect(result).to be_success
        expect(result.payload).to eq [namespace_1]
      end
    end
  end
end
