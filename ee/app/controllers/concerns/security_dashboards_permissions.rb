# frozen_string_literal: true

module SecurityDashboardsPermissions
  extend ActiveSupport::Concern

  VULNERABLE_POLICIES = {
    group: :read_group_security_dashboard,
    instance_security_dashboard: :read_instance_security_dashboard,
    project: :read_project_security_dashboard
  }.freeze

  included do
    before_action :ensure_security_dashboard_feature_enabled!
    before_action :authorize_read_security_dashboard!
  end

  protected

  def ensure_security_dashboard_feature_enabled!
    render_404 unless vulnerable.feature_available?(:security_dashboard)
  end

  def authorize_read_security_dashboard!
    render_403 unless can?(current_user, read_security_dashboard, vulnerable)
  end

  def read_security_dashboard
    VULNERABLE_POLICIES[vulnerable.class.name.underscore.to_sym]
  end
end
