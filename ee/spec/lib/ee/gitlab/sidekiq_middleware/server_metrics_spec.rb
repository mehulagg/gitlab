# frozen_string_literal: true

require 'spec_helper'

# rubocop: disable RSpec/MultipleMemoizedHelpers
RSpec.describe Gitlab::SidekiqMiddleware::ServerMetrics do
  context "with worker attribution" do
    subject { described_class.new }

    let(:queue) { :test }
    let(:worker_class) { worker.class }
    let(:job) { {} }
    let(:job_status) { :done }
    let(:labels_with_job_status) { labels.merge(job_status: job_status.to_s) }
    let(:default_labels) do
      { queue: queue.to_s,
        worker: worker_class.to_s,
        boundary: "",
        external_dependencies: "no",
        feature_category: "",
        urgency: "low",
        data_consistency: "always" }
    end

    shared_examples "a metrics middleware" do
      context "with mocked prometheus" do
        include_context 'server metrics with mocked prometheus'


        context 'when load_balancing is enabled' do
          let(:load_balancing_caught_up_fallbacks_metric) { double('load balancing caught up fallbacks metric') }
          let(:load_balancing_use_primary_metric) { double('load balancing use primary metric') }
          let(:load_balancing_use_replica_metric) { double('load balancing use replica metric') }
          let(:load_balancing_wait_for_replica_metric) { double('load balancing wait for replica metric') }

          include_context 'clear DB Load Balancing configuration'

          before do
            allow(::Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(true)
            allow(Gitlab::Metrics).to receive(:counter).with(:sidekiq_load_balancing_caught_up_fallbacks_count, anything).and_return(load_balancing_caught_up_fallbacks_metric)
            allow(Gitlab::Metrics).to receive(:counter).with(:sidekiq_load_balancing_use_primary_count, anything).and_return(load_balancing_use_primary_metric)
            allow(Gitlab::Metrics).to receive(:counter).with(:sidekiq_load_balancing_use_replica_count, anything).and_return(load_balancing_use_replica_metric)
            allow(Gitlab::Metrics).to receive(:counter).with(:sidekiq_load_balancing_wait_for_replica_count, anything).and_return(load_balancing_wait_for_replica_metric)
          end

          describe '#initialize' do
            it 'sets load_balancing metrics' do
              expect(Gitlab::Metrics).to receive(:counter).with(:sidekiq_load_balancing_caught_up_fallbacks_count, anything).and_return(load_balancing_caught_up_fallbacks_metric)
              expect(Gitlab::Metrics).to receive(:counter).with(:sidekiq_load_balancing_use_primary_count, anything).and_return(load_balancing_use_primary_metric)
              expect(Gitlab::Metrics).to receive(:counter).with(:sidekiq_load_balancing_use_replica_count, anything).and_return(load_balancing_use_replica_metric)
              expect(Gitlab::Metrics).to receive(:counter).with(:sidekiq_load_balancing_wait_for_replica_count, anything).and_return(load_balancing_wait_for_replica_metric)

              subject
            end
          end

          describe '#call' do
            include_context 'server metrics call'
              context 'when primary is used' do
                before do
                  job[:use_primary] = true
                  allow(load_balancing_use_primary_metric).to receive(:increment)
                end

                it 'increment sidekiq_load_balancing_use_primary_count' do
                  expect(load_balancing_use_primary_metric).to receive(:increment).with(labels_with_job_status, 1)

                  described_class.new.call(worker, job, :test) { nil }
                end

                context 'when replica has not caught up' do
                  before do
                    job[:fallback_to_primary] = true
                    allow(load_balancing_caught_up_fallbacks_metric).to receive(:increment)
                  end

                  it 'increment sidekiq_load_balancing_caught_up_fallbacks_count' do
                    expect(load_balancing_caught_up_fallbacks_metric).to receive(:increment).with(labels_with_job_status, 1)

                    described_class.new.call(worker, job, :test) { nil }
                  end
                end
              end

              context 'when replica is used' do
                before do
                  job[:use_primary] = false
                  allow(load_balancing_use_replica_metric).to receive(:increment)
                end

                it 'increment sidekiq_load_balancing_use_replica' do
                  expect(load_balancing_use_replica_metric).to receive(:increment).with(labels_with_job_status, 1)

                  described_class.new.call(worker, job, :test) { nil }
                end
              end

              context 'when worker waits for replica' do
                before do
                  job[:wait_for_replica] = true
                  allow(load_balancing_wait_for_replica_metric).to receive(:increment)
                end

                it 'increment sidekiq_load_balancing_wait_for_replica_count' do
                  expect(load_balancing_wait_for_replica_metric).to receive(:increment).with(labels_with_job_status, 1)

                  described_class.new.call(worker, job, :test) { nil }
                end
              end
            end

        end

        context 'when load_balancing is disabled' do

          include_context 'clear DB Load Balancing configuration'

          before do
            allow(::Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(false)
          end


          describe '#initialize' do
            it 'doesnt set load_balancing metrics' do
              expect(Gitlab::Metrics).not_to receive(:counter).with(:sidekiq_load_balancing_caught_up_fallbacks_count, anything)
              expect(Gitlab::Metrics).not_to receive(:counter).with(:sidekiq_load_balancing_use_primary_count, anything)
              expect(Gitlab::Metrics).not_to receive(:counter).with(:sidekiq_load_balancing_use_replica_count, anything)
              expect(Gitlab::Metrics).not_to receive(:counter).with(:sidekiq_load_balancing_wait_for_replica_count, anything)

              subject
            end
          end
        end
      end

      context "with prometheus integrated" do
        include_examples 'server metrics with prometheus integrated'
      end
    end

    include_examples 'server_metrics worker examples'
  end
end
# rubocop: enable RSpec/MultipleMemoizedHelpers
