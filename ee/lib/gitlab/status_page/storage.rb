# frozen_string_literal: true

module Gitlab
  module StatusPage
    module Storage
      # Size limit of the generated JSON uploaded to CDN.
      JSON_MAX_SIZE = 1.megabyte
      # Limit the amount of the recent incidents in the JSON list
      MAX_RECENT_INCIDENTS = 20
      # Limit the amount of comments per incident
      MAX_COMMENTS = 100
      # Limit on paginated responses
      MAX_KEYS_PER_PAGE = 1_000
      MAX_PAGES = 5
      MAX_UPLOADS = MAX_KEYS_PER_PAGE * MAX_PAGES

      class << self
        def details_path(id)
          "data/incident/#{id}.json"
        end

        def details_url(issue)
          return unless published_issue_available?(issue, issue.project.status_page_setting)

          issue.project.status_page_setting.normalized_status_page_url +
            CGI.escape(details_path(issue.iid))
        end

        def upload_path(issue_iid, secret, file_name)
          uploads_path = uploads_path(issue_iid)

          File.join(uploads_path, secret, file_name)
        end

        def uploads_path(issue_iid)
          File.join('data', 'incident', issue_iid.to_s, '/')
        end

        def list_path
          'data/list.json'
        end

        private

        def published_issue_available?(issue, setting)
          issue.status_page_published_incident &&
            setting&.enabled? &&
            setting&.status_page_url
        end
      end

      class Error < StandardError
        def initialize(bucket:, error:, **args)
          super(
            "Error occurred #{error.class.name.inspect} " \
            "for bucket #{bucket.inspect}. " \
            "Arguments: #{args.inspect}"
          )
        end
      end
    end
  end
end
