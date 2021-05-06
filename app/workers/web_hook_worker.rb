# frozen_string_literal: true

# Worker cannot be idempotent: https://gitlab.com/gitlab-org/gitlab/-/issues/218559
# rubocop:disable Scalability/IdempotentWorker
class WebHookWorker
  include ApplicationWorker

  feature_category :integrations
  worker_has_external_dependencies!
  loggable_arguments 2

  sidekiq_options retry: 4, dead: false

  class << self
    def perform_async(hook_id, data, hook_name)
      return super unless rate_limited?(hook_id)

      Gitlab::AuthLogger.error(
        message: 'Webhook rate limit exceeded',
        hook_id: hook_id,
        hook_name: hook_name
      )

      # Also log into application log for now, so we can use this information
      # to determine suitable limits for gitlab.com
      Gitlab::AppLogger.error(
        message: 'Webhook rate limit exceeded',
        class: name,
        hook_id: hook_id,
        hook_name: hook_name
      )
    end

    private

    def rate_limited?(hook_id)
      return false unless Feature.enabled?(:web_hooks_rate_limit, default_enabled: :yaml)

      hook = WebHook.find(hook_id)
      limits = current_plan_limits(hook)

      Gitlab::ApplicationRateLimiter.throttled?(
        :web_hook_calls,
        scope: [hook],
        threshold: limits.web_hook_calls
      )
    end

    def current_plan_limits(_hook)
      Plan.default.actual_limits
    end
  end

  def perform(hook_id, data, hook_name)
    hook = WebHook.find(hook_id)
    data = data.with_indifferent_access

    WebHookService.new(hook, data, hook_name).execute
  end
end
# rubocop:enable Scalability/IdempotentWorker

WebHookWorker.prepend_if_ee('EE::WebHookWorker')
