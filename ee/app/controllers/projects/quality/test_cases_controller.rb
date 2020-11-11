# frozen_string_literal: true

class Projects::Quality::TestCasesController < Projects::ApplicationController
  include IssuableActions

  prepend_before_action :authenticate_user!, only: [:new]

  before_action :check_quality_management_available!
  before_action :authorize_read_issue!
  before_action :verify_test_cases_flag!
  before_action :authorize_create_issue!, only: [:new]

  before_action do
    push_frontend_feature_flag(:quality_test_cases, project)
  end

  feature_category :quality_management

  def index
    respond_to do |format|
      format.html
    end
  end

  def new
    respond_to do |format|
      format.html
    end
  end

  private

  def test_case
    strong_memoize(:test_case) do
      incident_finder
        .execute
        .inc_relations_for_view
        .iid_in(params[:id])
        .without_order
        .first
    end
  end

  def load_incident
    @issue = test_case # needed by rendered view
    return render_404 unless can?(current_user, :read_issue, test_case)

    @noteable = test_case
    @note = incident.project.notes.new(noteable: @noteable)
  end

  alias_method :issuable, :test_case

  def verify_test_cases_flag!
    render_404 unless Feature.enabled?(:quality_test_cases, project)
  end

  def incident_finder
    IssuesFinder.new(current_user, project_id: @project.id, issue_types: :test_case)
  end

  def serializer
    IssueSerializer.new(current_user: current_user, project: test_case.project)
  end
end
