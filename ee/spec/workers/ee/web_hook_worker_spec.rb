# frozen_string_literal: true
require 'spec_helper'

RSpec.describe EE::WebHookWorker do
  let_it_be(:group_premium) { create(:group_with_plan, plan: :premium_plan) }
  let_it_be(:group_ultimate) { create(:group_with_plan, plan: :ultimate_plan) }
  let_it_be(:project_premium) { create(:project, group: group_premium) }
  let_it_be(:project_ultimate) { create(:project, group: group_ultimate) }
  let_it_be(:service_premium) { create(:service, project: project_premium) }
  let_it_be(:service_ultimate) { create(:service, project: project_ultimate) }

  let_it_be(:premium_hooks) do
    [
      create(:group_hook, group: group_premium),
      create(:project_hook, project: project_premium),
      create(:service_hook, service: service_premium)
    ]
  end

  let_it_be(:ultimate_hooks) do
    [
      create(:group_hook, group: group_ultimate),
      create(:project_hook, project: project_ultimate),
      create(:service_hook, service: service_ultimate)
    ]
  end

  let_it_be(:default_hooks) do
    [
      create(:group_hook),
      create(:project_hook),
      create(:service_hook)
    ]
  end

  let_it_be(:system_hook) { create(:system_hook) }

  describe '.perform_async' do
    def perform_async(hook)
      WebHookWorker.perform_async(hook.id, {}, 'push_hooks')
    end

    def expect_rate_limiter(hook, threshold:, throttled: false)
      expect(Gitlab::ApplicationRateLimiter).to receive(:throttled?)
        .with(:web_hook_calls, scope: [hook], threshold: threshold)
    end

    context 'when rate limiting is not configured' do
      it 'all hooks use a threshold of 0' do
        (premium_hooks + ultimate_hooks + default_hooks + [system_hook]).each do |hook|
          expect_rate_limiter(hook, threshold: 0)

          perform_async(hook)
        end
      end
    end

    context 'when rate limiting is configured on each plan' do
      let_it_be(:premium_plan) { create(:premium_plan) }
      let_it_be(:ultimate_plan) { create(:ultimate_plan) }
      let_it_be(:premium_limits) { create(:plan_limits, plan: premium_plan, web_hook_calls: 250) }
      let_it_be(:ultimate_limits) { create(:plan_limits, plan: ultimate_plan, web_hook_calls: 500) }
      let_it_be(:default_limits) { create(:plan_limits, :default_plan, web_hook_calls: 100) }

      it 'hooks with a Premium plan use the configured threshold' do
        premium_hooks.each do |hook|
          expect_rate_limiter(hook, threshold: 250)

          perform_async(hook)
        end
      end

      it 'hooks with an Ultimate plan use the configured threshold' do
        ultimate_hooks.each do |hook|
          expect_rate_limiter(hook, threshold: 500)

          perform_async(hook)
        end
      end

      it 'hooks with the default plan use the configured threshold' do
        default_hooks.each do |hook|
          expect_rate_limiter(hook, threshold: 100)

          perform_async(hook)
        end
      end

      it 'system hooks use the default threshold' do
        expect_rate_limiter(system_hook, threshold: 100)

        perform_async(system_hook)
      end

      context 'on gitlab.com' do
        let_it_be(:free_plan) { create(:free_plan) }
        let_it_be(:free_limits) { create(:plan_limits, plan: free_plan, web_hook_calls: 50) }

        before do
          allow(Gitlab).to receive(:com?).and_return(true)
        end

        it 'hooks with a Free plan use the configured threshold' do
          default_hooks.each do |hook|
            expect_rate_limiter(hook, threshold: 50)

            perform_async(hook)
          end
        end

        it 'system hooks use the default threshold' do
          expect_rate_limiter(system_hook, threshold: 100)

          perform_async(system_hook)
        end
      end
    end
  end
end
