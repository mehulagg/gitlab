# frozen_string_literal: true

module ComplianceManagement
  class FrameworkPolicy < BasePolicy
    delegate { @subject.namespace }

    condition(:custom_compliance_frameworks_enabled) do
      @subject.namespace.feature_available?(:custom_compliance_frameworks) &&
        Feature.enabled?(:ff_custom_compliance_frameworks, @subject.namespace)
    end

    rule { can?(:owner_access) & custom_compliance_frameworks_enabled }.policy do
      enable :manage_compliance_framework
    end
  end
end
