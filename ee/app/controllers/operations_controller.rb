# frozen_string_literal: true

class OperationsController < ApplicationController
  before_action :authorize_read_operations_dashboard!

  respond_to :json, only: [:list]

  feature_category :release_orchestration

  POLLING_INTERVAL = 120_000

  def index
  end

  def environments
  end

  def list
    Gitlab::PollingInterval.set_header(response, interval: POLLING_INTERVAL)
    projects = load_projects

    render json: { projects: serialize_as_json(projects) }
  end

  def environments_list
    Gitlab::PollingInterval.set_header(response, interval: POLLING_INTERVAL)
    projects = load_environments_projects

    render json: { projects: serialize_as_json_for_environments(projects) }
  end

  def create
    project_ids = params['project_ids']

    result = add_projects(project_ids)

    render json: {
      added: result.added_project_ids,
      duplicate: result.duplicate_project_ids,
      invalid: result.invalid_project_ids
    }
  end

  def destroy
    project_id = params['project_id']

    if remove_project(project_id)
      head :ok
    else
      head :no_content
    end
  end

  private

  def authorize_read_operations_dashboard!
    render_404 unless can?(current_user, :read_operations_dashboard)
  end

  def load_projects
    Dashboard::Operations::ListService.new(current_user).execute
  end

  def load_environments_projects
    Dashboard::Environments::ListService.new(current_user).execute
  end

  def add_projects(project_ids)
    Dashboard::Projects::CreateService.new(
      current_user,
      current_user.ops_dashboard_projects,
      feature: :operations_dashboard
    ).execute(project_ids)
  end

  def remove_project(project_id)
    UsersOpsDashboardProjects::DestroyService.new(current_user).execute(project_id)
  end

  def serialize_as_json(projects)
    DashboardOperationsSerializer.new(current_user: current_user).represent(projects)
  end

  def serialize_as_json_for_environments(projects)
    DashboardEnvironmentsSerializer
      .new(current_user: current_user)
      .with_pagination(request, response)
      .represent(projects)
  end
end
