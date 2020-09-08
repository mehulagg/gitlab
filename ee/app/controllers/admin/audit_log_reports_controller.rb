# frozen_string_literal: true

class Admin::AuditLogReportsController < Admin::ApplicationController
  before_action :validate_audit_log_reports_available!

  feature_category :audit_events

  def index
    csv_data = AuditEvents::ExportCsvService.new(audit_log_reports_params).csv_data

    respond_to do |format|
      format.csv do
        stream_csv(csv_data)
      end
    end
  end

  private

  def validate_audit_log_reports_available!
    render_404 unless Feature.enabled?(:audit_log_export_csv) &&
      License.feature_available?(:admin_audit_log)
  end

  def csv_filename
    "audit-events-#{Time.current.to_i}.csv"
  end

  def audit_log_reports_params
    params.permit(:entity_type, :entity_id, :created_before, :created_after, :author_id)
  end

  def stream_csv(csv_enumerator)
    headers["Content-Length"] = nil
    headers["Cache-Control"] = "no-cache"
    headers['Content-Type'] = 'text/csv; charset=utf-8; header=present'
    headers['X-Accel-Buffering'] = 'no'
    headers['Content-Disposition'] = "attachment; filename=\"#{csv_filename}\""

    self.response_body = csv_enumerator
  end
end
