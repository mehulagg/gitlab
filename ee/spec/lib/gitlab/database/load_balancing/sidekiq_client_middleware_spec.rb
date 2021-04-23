# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::LoadBalancing::SidekiqClientMiddleware do
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

    shared_examples_for 'does not pass database locations' do
      it 'does not pass database locations', :aggregate_failures do
        middleware.call(worker_class, job, double(:queue), redis_pool) { 10 }

        expect(job['database_replica_location']).to be_nil
        expect(job['database_write_location']).to be_nil
      end
    end

    shared_examples_for 'mark data consistency location' do |data_consistency|
      include_context 'data consistency worker class', data_consistency, :load_balancing_for_test_data_consistency_worker

      let(:location) { '0/D525E3A8' }

      context 'when feature flag load_balancing_for_sidekiq is disabled' do
        before do
          stub_feature_flags(load_balancing_for_test_data_consistency_worker: false)
        end

        include_examples 'does not pass database locations'
      end

      context 'when write was not performed' do
        before do
          allow(Gitlab::Database::LoadBalancing::Session.current).to receive(:performed_write?).and_return(false)
        end

        it 'passes database_replica_location' do
          expect(middleware).to receive_message_chain(:load_balancer, :host, "database_replica_location").and_return(location)

          middleware.call(worker_class, job, double(:queue), redis_pool) { 10 }

          expect(job['database_replica_location']).to eq(location)
        end
      end

      context 'when write was performed' do
        before do
          allow(Gitlab::Database::LoadBalancing::Session.current).to receive(:performed_write?).and_return(true)
        end

        it 'passes primary write location', :aggregate_failures do
          expect(middleware).to receive_message_chain(:load_balancer, :primary_write_location).and_return(location)

          middleware.call(worker_class, job, double(:queue), redis_pool) { 10 }

          expect(job['database_write_location']).to eq(location)
        end
      end
    end

    let(:queue) { 'default' }
    let(:redis_pool) { Sidekiq.redis_pool }
    let(:worker_class) { 'TestDataConsistencyWorker' }
    let(:job) { { "job_id" => "a180b47c-3fd6-41b8-81e9-34da61c3400e" } }

    before do
      skip_feature_flags_yaml_validation
      skip_default_enabled_yaml_check
    end

    context 'when worker cannot be constantized' do
      let(:worker_class) { 'ActionMailer::MailDeliveryJob' }

      include_examples 'does not pass database locations'
    end

    context 'when worker class does not include ApplicationWorker' do
      let(:worker_class) { ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper }

      include_examples 'does not pass database locations'
    end

    context 'when worker data consistency is :always' do
      include_context 'data consistency worker class', :always, :load_balancing_for_test_data_consistency_worker

      include_examples 'does not pass database locations'
    end

    context 'when worker data consistency is :delayed' do
      include_examples  'mark data consistency location', :delayed
    end

    context 'when worker data consistency is :sticky' do
      include_examples  'mark data consistency location', :sticky
    end
  end
end
