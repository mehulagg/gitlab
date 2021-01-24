# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FetchSubscriptionPlansService do
  describe '#execute' do
    subject(:execute_service) { described_class.new(plan: plan).execute }

    let(:endpoint_url) { "#{EE::SUBSCRIPTIONS_URL}/gitlab_plans" }
    let(:plan) { 'bronze' }
    let(:response_mock) { double(body: [{ 'foo' => 'bar' }].to_json) }

    context 'when successully fetching plans data' do
      it 'returns parsed JSON' do
        expect(Gitlab::HTTP).to receive(:get)
          .with(
            endpoint_url,
            allow_local_requests: true,
            query: { plan: plan, namespace_id: nil },
            headers: { 'Accept' => 'application/json' }
          )
          .and_return(response_mock)

        is_expected.to eq([Hashie::Mash.new('foo' => 'bar')])
      end

      it 'uses only the plan within the cache key name' do
        allow(Gitlab::HTTP).to receive(:get).and_return(response_mock)

        expect(Rails.cache).to receive(:read).with("pnp-subscription-plan-#{plan}")

        execute_service
      end

      context 'with given namespace_id' do
        subject(:execute_service) { described_class.new(plan: plan, namespace_id: namespace_id).execute }

        let(:namespace_id) { 87 }

        it 'returns parsed JSON' do
          expect(Gitlab::HTTP).to receive(:get)
            .with(
              endpoint_url,
              allow_local_requests: true,
              query: { plan: plan, namespace_id: namespace_id },
              headers: { 'Accept' => 'application/json' }
            )
            .and_return(response_mock)

          is_expected.to eq([Hashie::Mash.new('foo' => 'bar')])
        end

        it 'uses the namespace id within the cache key name' do
          allow(Gitlab::HTTP).to receive(:get).and_return(response_mock)

          expect(Rails.cache).to receive(:read).with("pnp-subscription-plan-#{plan}-#{namespace_id}")

          execute_service
        end
      end
    end

    context 'when failing to fetch plans data' do
      before do
        expect(Gitlab::HTTP).to receive(:get).and_raise(Gitlab::HTTP::Error.new('Error message'))
      end

      it 'logs failure' do
        expect(Gitlab::AppLogger).to receive(:info).with('Unable to connect to GitLab Customers App Error message')

        execute_service
      end

      it 'returns nil' do
        is_expected.to be_nil
      end
    end
  end
end
