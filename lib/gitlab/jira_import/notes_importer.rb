# frozen_string_literal: true

module Gitlab
  module JiraImport
    class NotesImporter
      BATCH_SIZE = 100
      attr_reader :project, :client, :formatter

      def initialize(project)
        @jira_project_key = project.import_data.data.dig('jira', 'project', 'key')

        raise Projects::ImportService::Error, 'Unable to find jira project to import data from.' unless @jira_project_key
        raise Projects::ImportService::Error, 'Jira intergration not configuresd' unless project.jira_service

        @project = project
        @client = project.jira_service.client
        @formatter = Gitlab::ImportFormatter.new
      end

      def execute
        import_notes
      end

      private

      def import_notes
        start_at = 0
        waiter = JobWaiter.new

        while start_at % BATCH_SIZE == 0
          issues = fetch_issuee_with_comments(start_at)
          start_at += issues.size

          schedule_issue_notes_import_workers(issues, waiter)
          project.import_state.refresh_jid_expiration
        end

        waiter
      end

      def schedule_issue_notes_import_workers(issues, waiter)
        issues.each do |jira_issue|
          # next if issue is not in the cache,
          # meaning it was not importer for some reason,
          # so we cannot save the note for it
          issue_id = get_issue_id_from_cache(jira_issue.id)
          next unless issue_id

          jira_issue.comments.each_slice(BATCH_SIZE) do |comments|
            mapped_comments = comments.map do |comment|
              next unless comment.body.present?

              note = ''
              note += formatter.author_line(comment.author['displayName'])
              note += comment.body # todo: GFM parsing

              {
                noteable_id: issue_id,
                noteable_type: 'Issue',
                project_id: project.id,
                note: note,
                author_id: project.creator_id, # todo: map actual author
                created_at: comment.created,
                updated_at: comment.updated
              }
            end

            Gitlab::JiraImport::BatchNotesImportWorker.perform_async(project.id, mapped_comments, waiter.key)
            waiter.jobs_remaining += 1
          end
        end
      end

      def fetch_issuee_with_comments(start_at)
        @client.Issue.jql(
          "PROJECT='#{@jira_project_key}' ORDER BY created ASC",
          {
            fields: ['comment'],
            max_results: BATCH_SIZE,
            start_at: start_at
          }
        )
      end

      def get_issue_id_from_cache(jira_issue_id)
        cache_key = JiraImport.jira_issue_cache_key(project.id, jira_issue_id)
        value = Gitlab::Cache::Import::Caching.read(cache_key)
        value.to_i if value.present?
      end
    end
  end
end
