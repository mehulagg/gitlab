# frozen_string_literal: true

class Projects::ClusterAgentsController < Projects::ApplicationController
  before_action :authorize_can_read_cluster_agent!

  feature_category :kubernetes_management

  def show
    @clusterable ||= ClusterablePresenter.fabricate(project, current_user: current_user)
    @agent_name = params[:name]
  end

  private

  def authorize_can_read_cluster_agent!
    access_denied! unless can?(current_user, :admin_cluster, project)
  end
end
