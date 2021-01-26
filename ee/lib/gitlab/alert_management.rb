# frozen_string_literal: true

module Gitlab
  module AlertManagement
    def self.custom_mapping_available?(project)
      ::Feature.enabled?(:multiple_http_integrations_custom_mapping, project) &&
        project.feature_available?(:multiple_alert_http_integrations)
    end
  end
end
