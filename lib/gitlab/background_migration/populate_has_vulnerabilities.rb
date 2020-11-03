# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # This class populates missing dismissal information for
    # vulnerability entries.
    class PopulateHasVulnerabilities
      class Project < ActiveRecord::Base # rubocop:disable Style/Documentation
        self.table_name = 'projects'

        has_one :project_setting

        def mark_as_vulnerable!
          project_setting.update!(has_vulnerabilities: true)
        end

        private

        def project_setting
          super || build_project_setting
        end
      end

      class ProjectSetting < ActiveRecord::Base # rubocop:disable Style/Documentation
        self.table_name = 'project_settings'

        belongs_to :project
      end

      class Vulnerability < ActiveRecord::Base # rubocop:disable Style/Documentation
        include EachBatch

        self.table_name = 'vulnerabilities'
      end

      def perform(*project_ids)
        Project.where(id: project_ids).includes(:project_setting).each do |project|
          project.mark_as_vulnerable!
        rescue StandardError => e
          log_error(e, project)
        end
      ensure
        log_info(project_ids)
      end

      private

      def log_error(error, project)
        ::Gitlab::BackgroundMigration::Logger.error(
          migrator: self.class.name,
          message: error.message,
          project_id: project.id
        )
      end

      def log_info(project_ids)
        ::Gitlab::BackgroundMigration::Logger.info(
          migrator: self.class.name,
          message: '`has_vulnerabilities` information has been populated',
          count: project_ids.length
        )
      end
    end
  end
end
