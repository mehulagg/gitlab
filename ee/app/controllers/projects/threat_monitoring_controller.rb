# frozen_string_literal: true

module Projects
  class ThreatMonitoringController < Projects::ApplicationController
    include SecurityAndCompliancePermissions

    before_action :authorize_read_threat_monitoring!

    before_action do
      push_frontend_feature_flag(:threat_monitoring_alerts, project, default_enabled: :yaml)
    end

    before_action :threat_monitoring_ff_enabled, only: [:alert_details]

    feature_category :web_firewall

    def alert_details
      @alert_id = project.alert_management_alerts.find(params[:id]).id
    end

    def edit
      @environment = project.environments.find(params[:environment_id])
      @policy_name = params[:id]
      response = NetworkPolicies::FindResourceService.new(
        resource_name: @policy_name,
        environment: @environment,
        kind: Gitlab::Kubernetes::CiliumNetworkPolicy::KIND
      ).execute

      if response.success?
        @policy = response.payload
      else
        render_404
      end
    end

    private

    def threat_monitoring_ff_enabled
      render_404 unless Feature.enabled?(:threat_monitoring_alerts, project, default_enabled: :yaml)
    end
  end
end
