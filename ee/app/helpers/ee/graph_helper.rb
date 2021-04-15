# frozen_string_literal: true

module EE
  module GraphHelper
    extend ::Gitlab::Utils::Override

    override :should_render_deployment_frequency_charts
    def should_render_deployment_frequency_charts
      return false unless ::Feature.enabled?(:deployment_frequency_charts, @project, default_enabled: true)
      return false unless @project.feature_available?(:dora4_analytics)

      can?(current_user, :read_dora4_analytics, @project)
    end

    override :should_render_lead_time_charts
    def should_render_lead_time_charts
      return false unless @project.feature_available?(:dora4_analytics)

      can?(current_user, :read_dora4_analytics, @project)
    end
  end
end
