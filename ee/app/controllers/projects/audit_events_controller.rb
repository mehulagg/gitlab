# frozen_string_literal: true

class Projects::AuditEventsController < Projects::ApplicationController
  include LicenseHelper

  before_action :authorize_admin_project!
  before_action :check_audit_events_available!

  layout 'project_settings'

  def index
    @events = LogFinder.new(entity_type: project.class.name, entity_id: project.id).execute.page(params[:page])
  end

  def check_audit_events_available!
    render_404 unless @project.feature_available?(:audit_events) || LicenseHelper.show_promotions?(current_user)
  end
end
