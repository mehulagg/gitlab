# frozen_string_literal: true

class Projects::AuditEventsController < Projects::ApplicationController
  include Gitlab::Utils::StrongMemoize
  include LicenseHelper
  include AuditEvents::EnforcesValidDateParams
  include AuditEvents::AuditLogsParams
  include AuditEvents::Sortable
  include AuditEvents::DateRange

  before_action :check_audit_events_available!

  feature_category :audit_events

  def index
    @is_last_page = events.last_page?
    @events = AuditEventSerializer.new.represent(events)

    Gitlab::Tracking.event(self.class.name, 'search_audit_event')
  end

  private

  def check_audit_events_available!
    render_404 unless can?(current_user, :read_project_audit_events, project) &&
      (project.feature_available?(:audit_events) || LicenseHelper.show_promotions?(current_user))
  end

  def events
    strong_memoize(:events) do
      level = Gitlab::Audit::Levels::Project.new(project: project)
      events = AuditLogFinder
        .new(level: level, params: audit_params)
        .execute
        .page(params[:page])
        .without_count

      Gitlab::Audit::Events::Preloader.preload!(events)
    end
  end

  def audit_params
    # This is an interim change until we have proper API support within Audit Events
    transform_author_entity_type(audit_logs_params)
  end

  def transform_author_entity_type(params)
    return params unless params[:entity_type] == 'Author'

    params[:author_id] = params[:entity_id]

    params.except(:entity_type, :entity_id)
  end
end
