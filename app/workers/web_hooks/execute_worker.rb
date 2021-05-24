# frozen_string_literal: true

module WebHooks
  # Worker cannot be idempotent: https://gitlab.com/gitlab-org/gitlab/-/issues/218559
  # rubocop:disable Scalability/IdempotentWorker
  class ExecuteWorker
    include ApplicationWorker

    feature_category :integrations
    worker_has_external_dependencies!
    loggable_arguments 2
    data_consistency :delayed, feature_flag: :load_balancing_for_web_hook_worker

    sidekiq_options retry: 4, dead: false

    def perform(hook_id, json_string, hook_name)
      hook = WebHook.find(hook_id)
      data = Gitlab::Json::PrecompiledJson.new(json_string)

      WebHookService.new(hook, data, hook_name).execute
    end
  end
  # rubocop:enable Scalability/IdempotentWorker
end
