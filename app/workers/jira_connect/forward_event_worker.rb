# frozen_string_literal: true

module JiraConnect
  class ForwardEventWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    sidekiq_options retry: 3

    queue_namespace :jira_connect
    feature_category :integrations
    loggable_arguments 1
    worker_has_external_dependencies!

    def perform(installation_id, auth_header)
      installation = JiraConnectInstallation.find_by_id(installation_id)

      return if installation.instance_url.nil?

      Gitlab::HTTP.post(installation.instance_url, headers: { 'Authorizationh' => auth_header })
    ensure
      installation.destroy
    end
  end
end
