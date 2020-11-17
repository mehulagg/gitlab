# frozen_string_literal: true

module IncidentManagement
  module OncallScheduleHelper
    def oncall_schedule_data(project)
      {
        'project-path' => project.full_path,
        'empty-oncall-schedule-svg-path' => image_path('illustrations/empty-state/empty-on-call.svg')
      }
    end
  end
end
