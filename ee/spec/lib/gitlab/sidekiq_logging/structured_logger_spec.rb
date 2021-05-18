# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SidekiqLogging::StructuredLogger do
  before do
    # We disable a memory instrumentation feature
    # as this requires a special patched Ruby
    allow(Gitlab::Memory::Instrumentation).to receive(:available?) { false }
  end

  describe '#call', :request_store do
    include_context 'structured_logger'

    RSpec.shared_examples 'performs database queries' do |load_balancing|
      include_context 'clear DB Load Balancing configuration'

      before do
        allow(Time).to receive(:now).and_return(timestamp)
        allow(Process).to receive(:clock_gettime).and_call_original
        allow(Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(load_balancing)
      end

      let(:expected_start_payload) { start_payload }

      let(:expected_end_payload) do
        end_payload.merge('cpu_s' => a_value >= 0)
      end

      it 'logs the database time', :aggregate_errors do
        expect(logger).to receive(:info).with(expected_start_payload).ordered
        expect(logger).to receive(:info).with(expected_end_payload_with_db).ordered

        call_subject(job, 'test_queue') do
          ActiveRecord::Base.connection.execute('SELECT pg_sleep(0.1);')
        end
      end

      it 'prevents database time from leaking to the next job', :aggregate_errors do
        expect(logger).to receive(:info).with(expected_start_payload).ordered
        expect(logger).to receive(:info).with(expected_end_payload_with_db).ordered
        expect(logger).to receive(:info).with(expected_start_payload).ordered
        expect(logger).to receive(:info).with(expected_end_payload).ordered

        call_subject(job.dup, 'test_queue') do
          ActiveRecord::Base.connection.execute('SELECT pg_sleep(0.1);')
        end

        Gitlab::SafeRequestStore.clear!

        call_subject(job.dup, 'test_queue') { }
      end
    end

    context 'when the job performs database queries' do
      context 'when load balancing is disabled' do
        let(:expected_end_payload_with_db) do
          expected_end_payload.merge(
            'db_duration_s' => a_value >= 0.1,
            'db_count' => a_value >= 1,
            'db_cached_count' => 0,
            'db_write_count' => 0
          )
        end

        include_examples 'performs database queries', false
      end

      context 'when load balancing is enabled' do
        let(:expected_end_payload_with_db) do
          expected_end_payload.merge(
            'db_duration_s' => a_value >= 0.1,
            'db_count' => a_value >= 1,
            'db_cached_count' => 0,
            'db_write_count' => 0,
            'db_replica_count' => 0,
            'db_replica_cached_count' => 0,
            'db_replica_wal_count' => 0,
            'db_replica_duration_s' => a_value >= 0,
            'db_primary_count' => a_value >= 1,
            'db_primary_cached_count' => 0,
            'db_primary_wal_count' => 0,
            'db_primary_duration_s' => a_value > 0
          )
        end

        let(:end_payload) do
          start_payload.merge(
            'message' => 'TestWorker JID-da883554ee4fe414012f5f42: done: 0.0 sec',
            'job_status' => 'done',
            'duration_s' => 0.0,
            'completed_at' => timestamp.to_f,
            'cpu_s' => 1.111112,
            'db_duration_s' => 0.0,
            'db_cached_count' => 0,
            'db_count' => 0,
            'db_write_count' => 0,
            'db_replica_count' => 0,
            'db_replica_cached_count' => 0,
            'db_replica_wal_count' => 0,
            'db_replica_duration_s' => 0,
            'db_primary_count' => 0,
            'db_primary_cached_count' => 0,
            'db_primary_wal_count' => 0,
            'db_primary_duration_s' => 0
          )
        end

        include_examples 'performs database queries', true
      end
    end

    context 'when the job uses load balancing capabilities' do
      let(:expected_payload) { { 'database_chosen' => 'retry' } }

      before do
        allow(Time).to receive(:now).and_return(timestamp)
        allow(Process).to receive(:clock_gettime).and_call_original
      end

      it 'logs the database chosen' do
        expect(logger).to receive(:info).with(start_payload).ordered
        expect(logger).to receive(:info).with(include(expected_payload)).ordered

        call_subject(job, 'test_queue') do
          job[:database_chosen] = 'retry'
        end
      end
    end

    def call_subject(job, queue)
      # This structured logger strongly depends on execution of `InstrumentationLogger`
      subject.call(job, queue) do
        ::Gitlab::SidekiqMiddleware::InstrumentationLogger.new.call('worker', job, queue) do
          yield
        end
      end
    end
  end
end
