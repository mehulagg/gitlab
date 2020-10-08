# frozen_string_literal: true

class Groups::AuditEventsController < Groups::ApplicationController
  include Gitlab::Utils::StrongMemoize
  include AuditEvents::EnforcesValidDateParams
  include AuditEvents::AuditLogsParams
  include AuditEvents::Sortable
  include AuditEvents::DateRange
  include Analytics::UniqueVisitsHelper

  before_action :authorize_admin_group!
  before_action :check_audit_events_available!

  track_unique_visits :index, target_id: 'g_compliance_audit_events'

  layout 'group_settings'

  feature_category :audit_events

  def index
    @is_last_page = events.last_page?
    @events = AuditEventSerializer.new.represent(events)
  end

  private

  def events
    strong_memoize(:events) do
      level = Gitlab::Audit::Levels::Group.new(group: group)
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
