# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      # This migration updates the states of vulnerabilities records to dismissed if the corresponding
      # vulnerability_occurrences record was dismissed.
      module UpdateVulnerabilitiesToDismissed
        extend ::Gitlab::Utils::Override

        VULNERABILITY_DETECTED = 1
        VULNERABILITY_DISMISSED = 2
        VULNERABILITY_FEEDBACK_DISMISSAL = 0

        class Project < ActiveRecord::Base
          self.table_name = 'projects'
          self.inheritance_column = :_type_disabled
        end

        override :perform
        def perform(project_id)
          project = Project.find_by(id: project_id)

          return unless project
          return if project.archived? || project.pending_delete?

          update_vulnerability_to_dismissed(project.id)
        end

        private

        def update_vulnerability_to_dismissed(project_id)
          update_vulnerability_to_dismissed_sql = <<-SQL
            UPDATE vulnerabilities
            SET state = #{VULNERABILITY_DISMISSED}
            FROM vulnerability_occurrences
            WHERE vulnerability_occurrences.vulnerability_id = vulnerabilities.id
              AND vulnerabilities.state = #{VULNERABILITY_DETECTED}
              AND (
                EXISTS (
                  SELECT 1
                  FROM vulnerability_feedback
                  WHERE vulnerability_occurrences.report_type = vulnerability_feedback.category
                    AND vulnerability_occurrences.project_id = vulnerability_feedback.project_id
                    AND ENCODE(vulnerability_occurrences.project_fingerprint, 'HEX') = vulnerability_feedback.project_fingerprint
                    AND vulnerability_feedback.feedback_type = #{VULNERABILITY_FEEDBACK_DISMISSAL}
                )
              )
              AND vulnerability_occurrences.project_id = #{project_id};
          SQL
          connection.execute(update_vulnerability_to_dismissed_sql)
        rescue StandardError => e
          logger.warn(
            message: 'update_vulnerability_to_dismissed errored out',
            project_id: project_id,
            error: e.message
          )
        end

        def connection
          @connection ||= ActiveRecord::Base.connection
        end

        def logger
          @logger ||= ::Gitlab::BackgroundMigration::Logger.build
        end
      end
    end
  end
end
