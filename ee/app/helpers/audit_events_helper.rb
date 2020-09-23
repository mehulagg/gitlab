# frozen_string_literal: true

module AuditEventsHelper
  FILTER_TOKEN_TYPES = {
      user: :user,
      group: :group,
      project: :project,
      member: :member
  }.freeze

  def admin_audit_event_tokens
    [{ type: FILTER_TOKEN_TYPES[:user] }, { type: FILTER_TOKEN_TYPES[:group] }, { type: FILTER_TOKEN_TYPES[:project] }].freeze
  end

  def group_audit_event_tokens(group_id)
    [{ type: FILTER_TOKEN_TYPES[:member], group_id: group_id }]
  end

  def project_audit_event_tokens(project_path)
    [{ type: FILTER_TOKEN_TYPES[:member], project_path: project_path }]
  end

  def human_text(details)
    return details[:custom_message] if details[:custom_message]

    details.map { |key, value| select_keys(key, value) }.join(" ").humanize
  end

  def select_keys(key, value)
    if key =~ /^(author|target)_.*/
      ""
    elsif key.to_s == 'ip_address' && value.blank?
      ""
    elsif key =~ /^expiry_(from|to)$/ && value.blank?
      "#{key} <strong>never expires</strong>"
    else
      "#{key} <strong>#{value}</strong>"
    end
  end

  def export_url
    Feature.enabled?(:audit_log_export_csv) ? admin_audit_log_reports_url(format: :csv) : ''
  end
end
