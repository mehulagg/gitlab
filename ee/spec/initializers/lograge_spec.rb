# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'lograge', type: :request do
  context 'with a log subscriber' do
    include_context 'parsed logs'
    include_context 'clear DB Load Balancing configuration'

    let(:subscriber) { Lograge::LogSubscribers::ActionController.new }

    let(:event) do
      ActiveSupport::Notifications::Event.new(
        'process_action.action_controller',
        Time.now,
        Time.now,
        2,
        status: 200,
        controller: 'HomeController',
        action: 'index',
        format: 'application/json',
        method: 'GET',
        path: '/home?foo=bar',
        params: {},
        db_runtime: 0.02,
        view_runtime: 0.01
      )
    end

    let(:logging_keys) do
      %w[db_primary_wal_count
         db_replica_wal_count
         db_replica_count
         db_replica_cached_count
         db_primary_count
         db_primary_cached_count
         db_primary_duration_s
         db_replica_duration_s]
    end

    context 'when load balancing is enabled' do
      before do
        allow(Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(true)
      end

      context 'with db payload' do
        context 'when RequestStore is enabled', :request_store do
          it 'includes db counters' do
            subscriber.process_action(event)
            expect(log_data).to include(*logging_keys)
          end
        end

        context 'when RequestStore is disabled' do
          it 'does not include db counters' do
            subscriber.process_action(event)

            expect(log_data).not_to include(*logging_keys)
          end
        end
      end
    end

    context 'when load balancing is disabled' do
      before do
        allow(Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(false)
      end

      it 'does not include db counters' do
        subscriber.process_action(event)

        expect(log_data).not_to include(*logging_keys)
      end
    end
  end
end
