# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      # This migration updates the dismissed_by_id and dismissed_at properties
      # of dimissed vulnerabilities records
      module UpdateVulnerabilitiesFromDismissalFeedback
        extend ::Gitlab::Utils::Override

        VULNERABILITY_DISMISSED_STATE = 2
        VULNERABILITY_FEEDBACK_DISMISSAL_TYPE = 0

        class Project < ActiveRecord::Base
          self.table_name = 'projects'
          self.inheritance_column = :_type_disabled
        end

        override :perform
        def perform(project_id)
          project = Project.find_by(id: project_id)

          return unless project
          return if project.pending_delete?

          update_vulnerability_from_dismissal_feedback(project.id)
        end

        private

        def update_vulnerability_from_dismissal_feedback(project_id)
          update_vulnerability_from_dismissal_feedback_sql = <<-SQL
          UPDATE vulnerabilities AS v
          SET dismissed_by_id = vf.author_id, dismissed_at = vf.created_at
          FROM vulnerability_occurrences AS vo, vulnerability_feedback AS vf
          WHERE vo.vulnerability_id = v.id
            AND v.state = #{VULNERABILITY_DISMISSED_STATE}
            AND vo.project_id = vf.project_id
            AND ENCODE(vo.project_fingerprint, 'HEX') = vf.project_fingerprint
            AND vo.project_id = #{project_id}
            AND vo.report_type = vf.category
            AND vf.feedback_type = #{VULNERABILITY_FEEDBACK_DISMISSAL_TYPE};
          SQL
          connection.execute(update_vulnerability_from_dismissal_feedback_sql)
        rescue StandardError => e
          logger.warn(
            message: 'update_vulnerability_from_dismissal_feedback errored out',
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
