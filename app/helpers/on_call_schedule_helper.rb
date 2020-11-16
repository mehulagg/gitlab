# frozen_string_literal: true

module Projects::OnCallScheduleHelper
  def on_call_schedule_data(project)
    {
        'project-path' => project.full_path,
        'empty-on-call-schedule-svg-path' => image_path('illustrations/empty-state/empty-on-call.svg'),
    }
  end
end
