# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Metrics::Subscribers::LoadBalancing do
  let(:env) { {} }
  let(:subscriber) { described_class.new }
  let(:connection) { double(:connection) }
  let(:payload) { { connection: connection } }

  let(:event) do
    double(
      :event,
      name: 'get_write_location.load_balancing',
      duration: 2,
      payload:  payload
    )
  end

  include_context 'clear DB Load Balancing configuration'

  before do
    allow(Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(true)
  end

  RSpec.shared_examples 'record LoadBalancing metrics in a metrics transaction' do
    it 'increments load_balancing counter' do
      expect(transaction).to receive(:increment).with(:gitlab_transaction_primary_write_location_count, 1)

      subscriber.get_write_location(event)
    end
  end

  it 'prevents db counters from leaking to the next transaction' do
    2.times do
      Gitlab::WithRequestStore.with_request_store do
        subscriber.get_write_location(event)

        expect(described_class.load_balancing_payload).to eq(primary_write_location: 1)
      end
    end
  end

  context 'when both web and background transaction are available' do
    let(:transaction) { double('Gitlab::Metrics::WebTransaction') }
    let(:background_transaction) { double('Gitlab::Metrics::WebTransaction') }

    before do
      allow(::Gitlab::Metrics::WebTransaction).to receive(:current).and_return(transaction)
      allow(::Gitlab::Metrics::BackgroundTransaction).to receive(:current).and_return(background_transaction)
      allow(transaction).to receive(:increment)
    end

    it_behaves_like 'record LoadBalancing metrics in a metrics transaction'

    it 'captures the metrics for web only' do
      expect(background_transaction).not_to receive(:increment)

      subscriber.get_write_location(event)
    end
  end

  context 'when web transaction is available' do
    let(:transaction) { double('Gitlab::Metrics::WebTransaction') }

    before do
      allow(::Gitlab::Metrics::WebTransaction).to receive(:current)
                                                    .and_return(transaction)
      allow(::Gitlab::Metrics::BackgroundTransaction).to receive(:current)
                                                           .and_return(nil)
      allow(transaction).to receive(:increment)
    end

    it_behaves_like 'record LoadBalancing metrics in a metrics transaction'
  end

  context 'when background transaction is available' do
    let(:transaction) { double('Gitlab::Metrics::BackgroundTransaction') }

    before do
      allow(::Gitlab::Metrics::WebTransaction).to receive(:current)
                                                    .and_return(nil)
      allow(::Gitlab::Metrics::BackgroundTransaction).to receive(:current)
                                                           .and_return(transaction)
      allow(transaction).to receive(:increment)
    end

    it_behaves_like 'record LoadBalancing metrics in a metrics transaction'
  end
end
