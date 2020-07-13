# frozen_string_literal: true

class Projects::AuditEventsController < Projects::ApplicationController
  include LicenseHelper
  include AuditEvents::EnforcesValidDateParams
  include AuditEvents::AuditLogsParams
  include AuditEvents::Sortable

  before_action :authorize_admin_project!
  before_action :check_audit_events_available!

  layout 'project_settings'

  def index
    level = Gitlab::Audit::Levels::Project.new(project: project)
    # This is an interim change until we have proper API support within Audit Events
    audit_params = transform_author_entity_type(audit_logs_params)

    events = AuditLogFinder
      .new(level: level, params: audit_params)
      .execute
      .page(params[:page])
      .without_count

    @events = Gitlab::Audit::Events::Preloader.preload!(events)
    @table_events = AuditEventSerializer.new.represent(@events)
  end

  private

  def check_audit_events_available!
    render_404 unless @project.feature_available?(:audit_events) || LicenseHelper.show_promotions?(current_user)
  end

  def transform_author_entity_type(params)
    return params unless params[:entity_type] == 'Author'

    params[:author_id] = params[:entity_id]

    params.except(:entity_type, :entity_id)
  end
end
