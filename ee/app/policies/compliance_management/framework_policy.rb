# frozen_string_literal: true

module ComplianceManagement
  class FrameworkPolicy < BasePolicy
    delegate { @subject.namespace }

    condition(:custom_compliance_frameworks_enabled) do
      License.feature_available?(:custom_compliance_frameworks) && Feature.enabled?(:ff_custom_compliance_frameworks)
    end

    condition(:force_includes_enabled) do
      License.feature_available?(:evaluate_group_level_compliance_pipeline) && Feature.enabled?(:ff_custom_compliance_frameworks)
    end

    rule { can?(:owner_access) & custom_compliance_frameworks_enabled }.policy do
      enable :manage_compliance_framework
    end

    rule { can?(:owner_access) & force_includes_enabled }.policy do
      enable :manage_compliance_force_includes
    end
  end
end
