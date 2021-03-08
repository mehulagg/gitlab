# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::CheckLastTermService do
  describe '#execute' do
    let(:namespace) { create(:namespace) }
    let(:namespace_id) { namespace.id }
    let(:cache_key) { "subscription_term:namespace_id:#{namespace_id}" }

    subject(:execute_service) { described_class.new(namespace_id: namespace_id).execute }

    shared_examples 'successful CustomersDot query' do
      let(:response) { { success: true, last_term: expected } }

      before do
        allow(Gitlab::SubscriptionPortal::Client).to receive(:last_term).and_return(response)
      end

      it 'returns the correct value' do
        expect(execute_service).to eq expected
      end
    end

    context 'when the subscription is in the last term' do
      let(:expected) { true }

      it_behaves_like 'successful CustomersDot query'
    end

    context 'when the subscription is not in the last term' do
      let(:expected) { false }

      it_behaves_like 'successful CustomersDot query'
    end

    context 'with an unsuccessful CustomersDot query' do
      it 'returns the correct value' do
        allow(Gitlab::SubscriptionPortal::Client).to receive(:last_term).and_return({
          success: false
        })

        expect(execute_service).to be_nil
      end
    end

    context 'with no cached response' do
      before do
        Rails.cache.delete(cache_key)

        allow(Gitlab::SubscriptionPortal::Client).to receive(:last_term).and_return({
          success: true,
          last_term: false
        })
      end

      it 'performs the query' do
        expect(Gitlab::SubscriptionPortal::Client).to receive(:last_term)

        execute_service
      end

      it 'caches the query response' do
        expect(Rails.cache).to receive(:fetch).with(cache_key, force: true, expires_in: 1.day).and_call_original

        execute_service
      end
    end

    context 'with a cached response' do
      before do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(true)
      end

      it 'returns the cached response' do
        expect(Gitlab::SubscriptionPortal::Client).not_to receive(:last_term)
        expect(Rails.cache).not_to receive(:fetch)

        expect(execute_service).to be true
      end
    end
  end
end
