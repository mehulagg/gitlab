# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Class to migrate service_desk_reply_to email addresses to issue_email_participants
    class PopulateIssueEmailParticipants
      def perform(start_id, stop_id)
        issues = Issue.where(id: (start_id..stop_id))

        rows = issues.map do |issue|
          {
          issue_id: issue.id,
          email: issue.service_desk_reply_to,
          created_at: issue.created_at,
          updated_at: issue.created_at
          }
        end

        Gitlab::Database.bulk_insert(:issue_email_participants, rows) # rubocop:disable Gitlab/BulkInsert
      end
    end
  end
end
