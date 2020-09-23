# frozen_string_literal: true

class Projects::InsightsController < Projects::ApplicationController
  include InsightsActions
  include Analytics::UniqueVisitsHelper

  helper_method :project_insights_config

  before_action :authorize_read_project!

  track_unique_visits :show, target_id: 'p_analytics_insights'

  private

  def insights_entity
    project
  end

  def config_data
    project_insights_config.filtered_config
  end

  def project_insights_config
    @project_insights_config ||= Gitlab::Insights::ProjectInsightsConfig.new(project: project, insights_config: insights_entity.insights_config)
  end
end
