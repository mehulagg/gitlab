# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    class BackfillCodeAnalyticsData
      NUM_MONTHS_TO_BACKFILL = 6
      MONTHLY_FREQUENCY = 1

      def perform
        projects_with_premium_license.each do |project|
          date_range_breakdown.each do |range|
            commits_in_range(project, range).each do |commit|
              edited_files(commit).each do |file, num_edits|
                repo_file = Analytics::CodeAnalytics::RepositoryFileEdits.upsert(file_path: file.file_path, project: project)

                upsert_repo_file_edits(repo_file, num_edits)
              end
            end
          end
        end
      end

      private

      def date_range_breakdown
        beginning_of_current_month = Date.today.at_beginning_of_month
        end_of_current_month = Date.today.at_end_of_month

        ranges = [beginning_of_current_month..Date.today]
        (1..NUM_MONTHS_TO_BACKFILL).each do |months|
          ranges.add ((beginning_of_current_month << months)..(send_of_current_month << months))
        end
        ranges
      end

      def upsert_repo_file_edits(repo_file, num_edits)
        Analytics::CodeAnalytics::RepositoryFileEdits.upsert(
          repo_file: repo_file,
          committed_date: commit.committed_date,
          project: project,
          num_edits: num_edits # add to previous value
        )
      end

      def projects_with_premium_license
      end

      # match each date with committed_at/date timestamp
      def commits_in_range(project, dates)
      end

      def dates
        180.days.ago..today
      end

      def edited_files(commit)
      end
    end
  end
end
