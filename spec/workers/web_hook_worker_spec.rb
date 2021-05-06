# frozen_string_literal: true
require 'spec_helper'

RSpec.describe WebHookWorker do
  include AfterNextHelpers

  let_it_be(:hook) { create(:project_hook) }
  let_it_be(:data) { { foo: 'bar' } }
  let_it_be(:hook_name) { 'push_hooks' }

  describe '.perform_async' do
    def perform_async(hook)
      described_class.perform_async(hook.id, data, hook_name)
    end

    def expect_job_for(hook)
      expect(described_class.jobs).to include(
        include('args' => [hook.id, data.stringify_keys, hook_name])
      )
    end

    def expect_jobs(count)
      expect(described_class.jobs.count).to be(count)
    end

    def expect_rate_limiter(threshold:, throttled: false)
      expect(Gitlab::ApplicationRateLimiter).to receive(:throttled?)
        .with(:web_hook_calls, scope: [hook], threshold: threshold)
        .and_return(throttled)
    end

    context 'when rate limiting is not configured' do
      it 'queues a job' do
        expect_rate_limiter(threshold: 0)

        perform_async(hook)

        expect_job_for(hook)
      end
    end

    context 'when rate limiting is configured' do
      let_it_be(:rate_limit) { 3 }
      let_it_be(:plan_limits) { create(:plan_limits, :default_plan, web_hook_calls: rate_limit) }

      it 'queues a job' do
        expect_rate_limiter(threshold: 3)

        perform_async(hook)

        expect_job_for(hook)
      end

      context 'when the hook is throttled (via mock)' do
        before do
          expect_rate_limiter(threshold: rate_limit, throttled: true)
        end

        it 'does not queue a job and logs an error' do
          expect(Gitlab::AuthLogger).to receive(:error).with(
            message: 'Webhook rate limit exceeded',
            hook_id: hook.id,
            hook_name: hook_name
          )

          expect(Gitlab::AppLogger).to receive(:error).with(
            message: 'Webhook rate limit exceeded',
            class: 'WebHookWorker',
            hook_id: hook.id,
            hook_name: hook_name
          )

          perform_async(hook)

          expect_jobs(0)
        end
      end

      context 'when the hook is throttled (via Redis)', :clean_gitlab_redis_cache do
        before do
          # Set a high interval to avoid intermittent failures in CI
          allow(Gitlab::ApplicationRateLimiter).to receive(:rate_limits).and_return(
            web_hook_calls: { interval: 1.day }
          )

          rate_limit.times { perform_async(hook) }

          expect_jobs(rate_limit)
        end

        it 'stops queueing jobs and logs errors' do
          expect(Gitlab::AuthLogger).to receive(:error).twice
          expect(Gitlab::AppLogger).to receive(:error).twice

          2.times { perform_async(hook) }

          expect_jobs(rate_limit)
        end

        it 'still queues jobs for other hooks' do
          other_hook = create(:project_hook)

          perform_async(other_hook)

          expect_jobs(rate_limit + 1)
          expect_job_for(other_hook)
        end
      end

      context 'when the feature flag is disabled' do
        before do
          stub_feature_flags(web_hooks_rate_limit: false)
        end

        it 'queues a job without tracking the call' do
          expect(Gitlab::ApplicationRateLimiter).not_to receive(:throttled?)

          perform_async(hook)

          expect_job_for(hook)
        end
      end
    end
  end

  describe '#perform' do
    it 'delegates to WebHookService' do
      expect_next(WebHookService, hook, data.with_indifferent_access, hook_name).to receive(:execute)

      subject.perform(hook.id, data, hook_name)
    end
  end
end
