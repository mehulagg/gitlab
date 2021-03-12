# frozen_string_literal: true

class ChatNotificationData
  attr_reader :raw_data

  def initialize(data, project)
    @raw_data = data.merge(project_url: project.web_url, project_name: project.full_name)
  end

  def event_type
    @event_type ||= raw_data[:event_type] || object_type
  end

  def object_type
    @object_type ||= raw_data[:object_kind]
  end

  def labels
    issue_labels = raw_data.dig(:issue, :labels) || []
    merge_request_labels = raw_data.dig(:merge_request, :labels) || []
    issue_labels + merge_request_labels
  end

  def user_id
    raw_data.dig(:user, :id) || raw_data[:user_id]
  end
end
