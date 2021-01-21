# frozen_string_literal: true

module StatusPage
  # Unpublish incident details from CDN.
  #
  # Example: An issue becomes confidential so it must be removed from CDN.
  #
  # This is an internal service which is part of
  # +StatusPage::PublishService+ and is not meant to be called directly.
  #
  # Consider calling +StatusPage::PublishService+ instead.
  class UnpublishDetailsService < PublishBaseService
    private

    def process(issue)
      PublishedIncident.untrack(issue)
      ::Gitlab::StatusPage::UsageDataCounters::IncidentCounter.count(:unpublishes)

      # Delete the incident prior to deleting images to avoid broken links
      json_key = json_object_key(issue)
      delete_object(json_key)

      upload_keys_prefix = uploads_path(issue)
      recursive_delete(upload_keys_prefix)

      success(object_key: json_key)
    end

    def uploads_path(issue)
      Gitlab::StatusPage::Storage.uploads_path(issue.iid)
    end

    def json_object_key(issue)
      Gitlab::StatusPage::Storage.details_path(issue.iid)
    end
  end
end
