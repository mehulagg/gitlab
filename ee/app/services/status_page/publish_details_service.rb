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
      publish_json_response = publish_json(issue, user_notes)
      return publish_json_response if publish_json_response.error?

      image_object_keys = publish_images(issue, user_notes)

      success_payload = publish_json_response.payload.merge({ image_object_keys: image_object_keys })

      success(success_payload)
    end

    # Publish Json

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

      StatusPage::Storage.details_path(id)
    end

    # Publish Images

    def publish_images(issue, user_notes)
      upload_keys = []
      existing_image_keys = storage_client.list_object_keys(StatusPage::Storage.uploads_path(issue.iid))

      upload_keys += publish_markdown_uploads(
        markdown_field: issue.description,
        issue_iid: issue.iid,
        existing_image_keys: existing_image_keys
      )
      user_notes.each do |user_note|
        upload_keys += publish_markdown_uploads(
          markdown_field: user_note.note,
          issue_iid: issue.iid,
          existing_image_keys: existing_image_keys
        )
      end

      upload_keys
    end

    def publish_markdown_uploads(markdown_field:, issue_iid:, existing_image_keys:)
      upload_keys = []
      markdown_field.scan(FileUploader::MARKDOWN_PATTERN).map do |md|
        key = StatusPage::Storage.upload_path(issue_iid, $~[:secret], $~[:file])
        next if existing_image_keys.include? key

        file = find_upload($~[:secret], $~[:file]).file.file
        upload_image(file, key)
        upload_keys << key
      end

      upload_keys
    end

    def upload_image(file, key)
      File.open(file) do |body|
        storage_client.upload_object(key, body)
      end
    end

    def find_upload(secret, file_path)
      uploader = FileUploader.new(@project, secret: secret)
      binding.pry
      uploader.retrieve_from_store!(file_path)
    end
  end
end
