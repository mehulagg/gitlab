# frozen_string_literal: true

require 'spec_helper'

# rubocop: disable RSpec/MultipleMemoizedHelpers
RSpec.describe Gitlab::SidekiqMiddleware::ServerMetrics do
  using RSpec::Parameterized::TableSyntax

  subject { described_class.new }

  let(:queue) { :test }
  let(:worker_class) { worker.class }
  let(:job) { {} }
  let(:job_status) { :done }
  let(:labels_with_job_status) { default_labels.merge(job_status: job_status.to_s) }
  let(:default_labels) do
    { queue: queue.to_s,
      worker: worker_class.to_s,
      boundary: "",
      external_dependencies: "no",
      feature_category: "",
      urgency: "low" }
  end

  before do
    stub_const('TestWorker', Class.new)
    TestWorker.class_eval do
      include Sidekiq::Worker
      include WorkerAttributes
    end
  end

  let(:worker) { TestWorker.new }

  include_context 'server metrics with mocked prometheus'

  context 'when load_balancing is enabled' do
    let(:load_balancing_metric) { double('load balancing metric') }

    include_context 'clear DB Load Balancing configuration'

    before do
      allow(::Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(true)
      allow(Gitlab::Metrics).to receive(:counter).with(:sidekiq_load_balancing_count, anything).and_return(load_balancing_metric)
    end

    describe '#initialize' do
      it 'sets load_balancing metrics' do
        expect(Gitlab::Metrics).to receive(:counter).with(:sidekiq_load_balancing_count, anything).and_return(load_balancing_metric)

        subject
      end
    end

    describe '#call' do
      include_context 'server metrics call'

      context 'when :database_chosen is provided' do
        where(:database_chosen) do
          %w[primary retry replica]
        end

        with_them do
          context "when #{params[:database_chosen]} is used" do
            let(:labels_with_load_balancing) do
              labels_with_job_status.merge(database_chosen: database_chosen, data_consistency: 'delayed')
            end

            before do
              job[:database_chosen] = database_chosen
              job[:data_consistency] = 'delayed'
              allow(load_balancing_metric).to receive(:increment)
            end

            it 'increment sidekiq_load_balancing_count' do
              expect(load_balancing_metric).to receive(:increment).with(labels_with_load_balancing, 1)

              described_class.new.call(worker, job, :test) { nil }
            end
          end
        end
      end

      context 'when :database_chosen is not provided' do
        it 'does not increment sidekiq_load_balancing_count' do
          expect(load_balancing_metric).not_to receive(:increment)

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
        expect(Gitlab::Metrics).not_to receive(:counter).with(:sidekiq_load_balancing_count, anything)

        subject
      end
    end
  end
end
