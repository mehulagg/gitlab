# frozen_string_literal: true

module EE
  module ApplicationController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      around_action :set_current_ip_address
    end

    def verify_namespace_plan_check_enabled
      render_404 unless ::Gitlab::CurrentSettings.should_check_namespace_plan?
    end

    override :after_sign_out_path_for
    def after_sign_out_path_for(resource)
      if ::Gitlab::Geo.secondary?
        ::Gitlab::Geo.primary_node.oauth_logout_url(@geo_logout_state) # rubocop:disable Gitlab/ModuleWithInstanceVariables
      else
        super
      end
    end

    private

    override :log_impersonation_event
    def log_impersonation_event
      super

      log_audit_event
    end

    def log_audit_event
      AuditEvents::ImpersonationAuditEventService.new(impersonator, request.remote_ip, 'Stopped Impersonation')
        .for_user(full_path: current_user.username, entity_id: current_user.id).security_event
    end

    def set_current_ip_address(&block)
      ::Gitlab::IpAddressState.with(request.ip, &block) # rubocop: disable CodeReuse/ActiveRecord
    end
  end
end
