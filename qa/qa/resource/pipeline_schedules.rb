# frozen_string_literal: true

module QA
  module Resource
    class PipelineSchedules < Base
      attribute :id
      attribute :ref
      attribute :description

      # Cron schedule form "* * * * *"
      # String of integers order of "minute hour day-of-mont month day-of-week"
      attribute :cron

      attribute :project do
        Resource::Project.fabricate! do |project|
          project.name = 'project-with-pipeline-schedule'
        end
      end

      def initialize
        @cron = '0 * * * *' # default to schedule at the beginning of the hour
        @description = "QA test scheduling pipeline."
        @ref = project.default_branch
      end

      def api_get_path
        "/projects/#{project.id}/pipeline_schedules/#{id}"
      end

      def api_post_path
        "/projects/#{project.id}/pipeline_schedules"
      end

      def api_post_body
        {
            description: description,
            ref: ref,
            cron: cron
        }
      end
    end
  end
end
