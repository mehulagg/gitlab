# frozen_string_literal: true

module EE::Projects::Analytics::CycleAnalytics::SummaryController
  extend ::Gitlab::Utils::Override

  private

  override :allowed_params
  def allowed_params
    return super unless @project.licensed_feature_available?(:cycle_analytics_for_projects) # rubocop: disable Gitlab/ModuleWithInstanceVariables

    request_params.to_data_collector_params
  end
end
