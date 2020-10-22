# frozen_string_literal: true

class InstanceSecurityDashboardPolicy < BasePolicy
  with_scope :global
  condition(:security_dashboard_enabled) do
    License.feature_available?(:security_dashboard)
  end

  rule { ~anonymous }.enable :read_instance_security_dashboard
  rule { security_dashboard_enabled & can?(:read_instance_security_dashboard) }.enable :create_vulnerability_export
end
