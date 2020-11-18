# frozen_string_literal: true

module EE
  module NamespacePolicy
    extend ActiveSupport::Concern

    prepended do
      condition(:custom_compliance_frameworks_enabled) { License.feature_available?(:custom_compliance_frameworks) }
      condition(:over_storage_limit, scope: :subject) { @subject.over_storage_limit? }

      rule { admin & is_gitlab_com }.enable :update_subscription_limit

      rule { over_storage_limit }.policy do
        prevent :create_projects
      end

      rule { (owner | admin) & custom_compliance_frameworks_enabled }.policy do
        enable :create_custom_compliance_frameworks
      end
    end
  end
end
