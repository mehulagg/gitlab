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
        Project.where(id: project_ids).each { |project| project.mark_as_vulnerable! }
      end
    end
  end
end
