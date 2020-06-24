# frozen_string_literal: true

class Groups::AuditEventsController < Groups::ApplicationController
  include AuditEvents::EnforcesValidDateParams
  include AuditEvents::AuditLogsParams
  include AuditEvents::Sortable

  before_action :authorize_admin_group!
  before_action :check_audit_events_available!

  layout 'group_settings'

  def index
    level = Gitlab::Audit::Levels::Group.new(group: group)
    # This is an interim change until we have proper API support within Audit Events
    params = transform_author_entity_type(audit_logs_params)

    events = AuditLogFinder
      .new(level: level, params: params)
      .execute
      .page(params[:page])
      .without_count

    @events = Gitlab::Audit::Events::Preloader.preload!(events)
    @table_events = AuditEventSerializer.new.represent(@events)
  end

  private

  def transform_author_entity_type(params)
    return params unless params[:entity_type] == 'Author'

    params[:author_id] = params[:entity_id]

    params.except(:entity_type, :entity_id)
  end
end
