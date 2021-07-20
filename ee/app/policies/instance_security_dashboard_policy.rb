# frozen_string_literal: true

class InstanceSecurityDashboardPolicy < BasePolicy
  with_scope :global
  condition(:security_dashboard_enabled) do
    License.feature_available?(:security_dashboard)
  end

  rule { ~anonymous }.policy do
    enable :read_instance_security_dashboard
    enable :read_security_resource
  end

  rule { security_dashboard_enabled & can?(:read_instance_security_dashboard) }.enable :create_vulnerability_export
end
