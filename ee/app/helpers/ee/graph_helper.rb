# frozen_string_literal: true

module EE
  module GraphHelper
    extend ::Gitlab::Utils::Override

    override :should_render_dora_charts
    def should_render_dora_charts
      return false unless @project.feature_available?(:dora4_analytics)

      can?(current_user, :read_dora4_analytics, @project)
    end
  end
end
