# frozen_string_literal: true

module IncidentManagement
  class ProcessAlertWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    queue_namespace :incident_management
    feature_category :incident_management

    # `project_id` and `alert_payload` are deprecated and can be removed
    # starting from 14.0 release
    # https://gitlab.com/gitlab-org/gitlab/-/issues/224500
    def perform(_project_id = nil, _alert_payload = nil, _alert_id = nil)
      # no-op
      #
      # This worker is not scheduled anymore since
      # https://gitlab.com/gitlab-org/gitlab/-/merge_requests/60285
      # and will be removed completely via
      # https://gitlab.com/gitlab-org/gitlab/-/issues/224500
      # in 14.0.
    end
  end
end
