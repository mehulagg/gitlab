# frozen_string_literal: true

class Projects::IncidentsController < Projects::ApplicationController
  include IssuableActions
  include Gitlab::Utils::StrongMemoize

  before_action :authorize_read_incidents!
  before_action :load_incident, only: [:show]

  def index
  end

  private

  def incident
    strong_memoize(:incident) do
      incident_finder.execute.includes(author: :status).first!
    end
  end

  def load_incident
    @issue = incident # hack to make copied HAML view work
    @noteable = incident
    @note = incident.project.notes.new(noteable: issuable)

    return render_404 unless can?(current_user, :read_incidents, incident)
  end

  alias_method :issuable, :incident

  def incident_finder
    IssuesFinder.new(
      current_user,
      project_id: @project.id,
      issue_types: :incident,
      iids: [params[:id]]
    )
  end

  def serializer
    IssueSerializer.new(current_user: current_user, project: incident.project)
  end
end
