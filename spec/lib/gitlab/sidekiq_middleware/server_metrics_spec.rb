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

        describe '#initialize' do
          it 'sets concurrency metrics' do
            expect(concurrency_metric).to receive(:set).with({}, Sidekiq.options[:concurrency].to_i)

            subject
          end
        end

        describe '#call' do
          include_context 'server metrics call'

          it 'yields block' do
            expect { |b| subject.call(worker, job, :test, &b) }.to yield_control.once
          end

          it 'calls BackgroundTransaction' do
            expect_next_instance_of(Gitlab::Metrics::BackgroundTransaction) do |instance|
              expect(instance).to receive(:run)
            end

            subject.call(worker, job, :test) {}
          end

          it 'sets queue specific metrics' do
            expect(running_jobs_metric).to receive(:increment).with(labels, -1)
            expect(running_jobs_metric).to receive(:increment).with(labels, 1)
            expect(queue_duration_seconds).to receive(:observe).with(labels, queue_duration_for_job) if queue_duration_for_job
            expect(user_execution_seconds_metric).to receive(:observe).with(labels_with_job_status, thread_cputime_duration)
            expect(db_seconds_metric).to receive(:observe).with(labels_with_job_status, db_duration)
            expect(gitaly_seconds_metric).to receive(:observe).with(labels_with_job_status, gitaly_duration)
            expect(completion_seconds_metric).to receive(:observe).with(labels_with_job_status, monotonic_time_duration)
            expect(redis_seconds_metric).to receive(:observe).with(labels_with_job_status, redis_duration)
            expect(elasticsearch_seconds_metric).to receive(:observe).with(labels_with_job_status, elasticsearch_duration)
            expect(redis_requests_total).to receive(:increment).with(labels_with_job_status, redis_calls)
            expect(elasticsearch_requests_total).to receive(:increment).with(labels_with_job_status, elasticsearch_calls)

            subject.call(worker, job, :test) { nil }
          end

          it 'sets the thread name if it was nil' do
            allow(Thread.current).to receive(:name).and_return(nil)
            expect(Thread.current).to receive(:name=).with(Gitlab::Metrics::Samplers::ThreadsSampler::SIDEKIQ_WORKER_THREAD_NAME)

            subject.call(worker, job, :test) { nil }
          end

          context 'when job_duration is not available' do
            let(:queue_duration_for_job) { nil }

            it 'does not set the queue_duration_seconds histogram' do
              expect(queue_duration_seconds).not_to receive(:observe)

              subject.call(worker, job, :test) { nil }
            end
          end

          context 'when error is raised' do
            let(:job_status) { :fail }

            it 'sets sidekiq_jobs_failed_total and reraises' do
              expect(failed_total_metric).to receive(:increment).with(labels, 1)

              expect { subject.call(worker, job, :test) { raise StandardError, "Failed" } }.to raise_error(StandardError, "Failed")
            end
          end

          context 'when job is retried' do
            let(:job) { { 'retry_count' => 1 } }

            it 'sets sidekiq_jobs_retried_total metric' do
              expect(retried_total_metric).to receive(:increment)

              subject.call(worker, job, :test) { nil }
            end
          end
        end
      end

      context "with prometheus integrated" do
        describe '#call' do
          it 'yields block' do
            expect { |b| subject.call(worker, job, :test, &b) }.to yield_control.once
          end

          context 'when error is raised' do
            let(:job_status) { :fail }

            it 'sets sidekiq_jobs_failed_total and reraises' do
              expect { subject.call(worker, job, :test) { raise StandardError, "Failed" } }.to raise_error(StandardError, "Failed")
            end
          end
        end
      end
    end

    context "when workers are not attributed" do
      before do
        stub_const('TestNonAttributedWorker', Class.new)
        TestNonAttributedWorker.class_eval do
          include Sidekiq::Worker
        end
      end

      let(:worker) { TestNonAttributedWorker.new }
      let(:labels) { default_labels.merge(urgency: "", data_consistency: "") }

      it_behaves_like "a metrics middleware"
    end

    context "when a worker is wrapped into ActiveJob" do
      before do
        stub_const('TestWrappedWorker', Class.new)
        TestWrappedWorker.class_eval do
          include Sidekiq::Worker
        end
      end

      let(:job) do
        {
          "class" => ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper,
          "wrapped" => TestWrappedWorker
        }
      end

      let(:worker) { TestWrappedWorker.new }
      let(:worker_class) { TestWrappedWorker }
      let(:labels) { default_labels.merge(urgency: "", data_consistency: "") }

      it_behaves_like "a metrics middleware"
    end

    context 'for ActionMailer::MailDeliveryJob' do
      let(:job) { { 'class' => ActionMailer::MailDeliveryJob } }
      let(:worker) { ActionMailer::MailDeliveryJob.new }
      let(:worker_class) { ActionMailer::MailDeliveryJob }
      let(:labels) { default_labels.merge(feature_category: 'issue_tracking', data_consistency: '') }

      it_behaves_like 'a metrics middleware'
    end

    context "when workers are attributed" do
      def create_attributed_worker_class(urgency, external_dependencies, resource_boundary, category, data_consistency)
        Class.new do
          include Sidekiq::Worker
          include WorkerAttributes

          urgency urgency if urgency
          worker_has_external_dependencies! if external_dependencies
          worker_resource_boundary resource_boundary unless resource_boundary == :unknown
          feature_category category unless category.nil?
          data_consistency data_consistency unless data_consistency.nil?
        end
      end

      let(:urgency) { nil }
      let(:external_dependencies) { false }
      let(:resource_boundary) { :unknown }
      let(:feature_category) { nil }
      let(:data_consistency) { nil }
      let(:worker_class) { create_attributed_worker_class(urgency, external_dependencies, resource_boundary, feature_category, data_consistency) }
      let(:worker) { worker_class.new }

      context "high urgency" do
        let(:urgency) { :high }
        let(:labels) { default_labels.merge(urgency: "high") }

        it_behaves_like "a metrics middleware"
      end

      context "external dependencies" do
        let(:external_dependencies) { true }
        let(:labels) { default_labels.merge(external_dependencies: "yes") }

        it_behaves_like "a metrics middleware"
      end

      context "cpu boundary" do
        let(:resource_boundary) { :cpu }
        let(:labels) { default_labels.merge(boundary: "cpu") }

        it_behaves_like "a metrics middleware"
      end

      context "memory boundary" do
        let(:resource_boundary) { :memory }
        let(:labels) { default_labels.merge(boundary: "memory") }

        it_behaves_like "a metrics middleware"
      end

      context "feature category" do
        let(:feature_category) { :authentication }
        let(:labels) { default_labels.merge(feature_category: "authentication") }

        it_behaves_like "a metrics middleware"
      end

      context "data consistency" do
        let(:data_consistency) { :delayed }
        let(:labels) { default_labels.merge(data_consistency: "delayed") }

        it_behaves_like "a metrics middleware"
      end

      context "combined" do
        let(:urgency) { :throttled }
        let(:external_dependencies) { true }
        let(:resource_boundary) { :cpu }
        let(:feature_category) { :authentication }
        let(:data_consistency) { :delayed }
        let(:labels) do
          default_labels.merge(
            urgency: "throttled",
            external_dependencies: "yes",
            boundary: "cpu",
            feature_category: "authentication",
            data_consistency: "delayed")
        end

        it_behaves_like "a metrics middleware"
      end
    end
  end
end
# rubocop: enable RSpec/MultipleMemoizedHelpers
