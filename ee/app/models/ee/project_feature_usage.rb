# frozen_string_literal: true

module EE
  module ProjectFeatureUsage
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    override :log_jira_dvcs_integration_usage
    def log_jira_dvcs_integration_usage(**options)
      ::Gitlab::Database::LoadBalancing::Session.without_sticky_writes do
        super(**options)
      end
    end
  end
end
