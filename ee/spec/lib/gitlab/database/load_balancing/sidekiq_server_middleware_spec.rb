# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::LoadBalancing::SidekiqServerMiddleware do
  let(:middleware) { described_class.new }

  after do
    Gitlab::Database::LoadBalancing::Session.clear_session
  end

  describe '#call' do
    shared_context 'data consistency worker class' do |data_consistency, feature_flag|
      let(:worker_class) do
        Class.new do
          def self.name
            'TestDataConsistencyWorker'
          end

          include ApplicationWorker

          data_consistency data_consistency, feature_flag: feature_flag

          def perform(*args)
          end
        end
      end

      before do
        stub_const('TestDataConsistencyWorker', worker_class)
      end
    end

    shared_examples_for 'job marked with chosen database' do
      it 'yields and sets database chosen', :aggregate_failures do
        expect { |b| middleware.call(worker, job, double(:queue), &b) }.to yield_control

        expect(job[:database_chosen]).to eq('primary')
      end
    end

    shared_examples_for 'stick to the primary' do
      it 'sticks to the primary' do
        middleware.call(worker, job, double(:queue)) do
          expect(Gitlab::Database::LoadBalancing::Session.current.use_primary?).to be_truthy
        end
      end
    end

    shared_examples_for 'replica is up to date' do |location|
      it 'do not stick to the primary', :aggregate_failures do
        expect(middleware).to receive(:replica_caught_up?).with(location).and_return(true)

        middleware.call(worker, job, double(:queue)) do
          expect(Gitlab::Database::LoadBalancing::Session.current.use_primary?).not_to be_truthy
        end

        expect(job[:database_chosen]).to eq('replica')
      end
    end

    shared_examples_for 'sticks based on data consistency' do |data_consistency|
      include_context 'data consistency worker class', data_consistency, :load_balancing_for_test_data_consistency_worker

      context 'when load_balancing_for_test_data_consistency_worker is disabled' do
        before do
          stub_feature_flags(load_balancing_for_test_data_consistency_worker: false)
        end

        include_examples 'stick to the primary'
      end

      context 'when database replica location is set' do
        let(:job) { { 'job_id' => 'a180b47c-3fd6-41b8-81e9-34da61c3400e', 'database_replica_location' => '0/D525E3A8' } }

        before do
          allow(middleware).to receive(:replica_caught_up?).and_return(true)
        end

        it_behaves_like 'replica is up to date', '0/D525E3A8'
      end

      context 'when database primary location is set' do
        let(:job) { { 'job_id' => 'a180b47c-3fd6-41b8-81e9-34da61c3400e', 'database_write_location' => '0/D525E3A8' } }

        before do
          allow(middleware).to receive(:replica_caught_up?).and_return(true)
        end

        it_behaves_like 'replica is up to date', '0/D525E3A8'
      end

      context 'when database location is not set' do
        let(:job) { { 'job_id' => 'a180b47c-3fd6-41b8-81e9-34da61c3400e' } }

        it_behaves_like 'replica is up to date', nil
      end
    end

    let(:queue) { 'default' }
    let(:redis_pool) { Sidekiq.redis_pool }
    let(:worker) { worker_class.new }
    let(:job) { { "job_id" => "a180b47c-3fd6-41b8-81e9-34da61c3400e" } }
    let(:block) { 10 }

    before do
      skip_feature_flags_yaml_validation
      skip_default_enabled_yaml_check
      allow(middleware).to receive(:clear)
      allow(Gitlab::Database::LoadBalancing::Session.current).to receive(:performed_write?).and_return(true)
    end

    context 'when worker class does not include ApplicationWorker' do
      let(:worker) { ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.new }

      include_examples 'stick to the primary'
    end

    context 'when worker data consistency is :always' do
      include_context 'data consistency worker class', :always, :load_balancing_for_test_data_consistency_worker

      include_examples 'stick to the primary'
    end

    context 'when worker data consistency is :delayed' do
      include_examples 'sticks based on data consistency', :delayed

      context 'when replica is not up to date' do
        before do
          allow(middleware).to receive(:replica_caught_up?).and_return(false)
        end

        context 'when job is retried once' do
          it 'raise an error and retries' do
            expect { middleware.call(worker, job, double(:queue)) { block } }.to raise_error(Gitlab::Database::LoadBalancing::SidekiqServerMiddleware::JobReplicaNotUpToDate)
          end
        end

        context 'when job is retried more then once' do
          before do
            job['retry_count'] = 1
          end

          include_examples 'stick to the primary'
          include_examples 'job marked with chosen database'
        end
      end
    end

    context 'when worker data consistency is :sticky' do
      include_examples 'sticks based on data consistency', :sticky

      context 'when replica is not up to date' do
        before do
          allow(middleware).to receive(:replica_caught_up?).and_return(false)
        end

        include_examples 'stick to the primary'
        include_examples 'job marked with chosen database'
      end
    end
  end
end
