# frozen_string_literal: true

class Projects::IterationsController < Projects::ApplicationController
  before_action :check_iterations_available!
  before_action :authorize_show_iteration!
  before_action do
    push_frontend_feature_flag(:iteration_charts, project, default_enabled: true)
    push_frontend_feature_flag(:burnup_charts, project, default_enabled: true)
  end

  feature_category :issue_tracking

  def index; end

  private

  def check_iterations_available!
    render_404 unless project.feature_available?(:iterations)
  end

  def authorize_show_iteration!
    render_404 unless can?(current_user, :read_iteration, project)
  end
end
