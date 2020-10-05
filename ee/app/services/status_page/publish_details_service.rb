# frozen_string_literal: true

module StatusPage
  # Render an issue as incident details and publish them to CDN.
  #
  # This is an internal service which is part of
  # +StatusPage::PublishService+ and is not meant to be called directly.
  #
  # Consider calling +StatusPage::PublishService+ instead.
  class PublishDetailsService < PublishBaseService
    private

    def process(issue, user_notes)
      response = publish_json(issue, user_notes)
      return response if response.error?

      response = publish_attachments(issue, user_notes)
      return response if response.error?

      success
    end

    def publish_json(issue, user_notes)
      json = serialize(issue, user_notes)
      key = json_object_key(json)
      return error('Missing object key') unless key

      upload_json(key, json)
    end

    def serialize(issue, user_notes)
      serializer.represent_details(issue, user_notes)
    end

    def json_object_key(json)
      id = json[:id]
      return unless id

      Gitlab::StatusPage::Storage.details_path(id)
    end

    def publish_attachments(issue, user_notes)
      StatusPage::PublishAttachmentsService.new(
        project: @project,
        issue: issue,
        user_notes: user_notes,
        storage_client: storage_client
      ).execute
    end
  end
end
