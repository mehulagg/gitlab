# frozen_string_literal: true

module OncallHelpers
  def active_period_for_date_with_tz(date, rotation)
    date = date.in_time_zone(rotation.schedule.timezone)

    rotation.active_period.for_date(date)
  end

  def create_schedule_with_user(project, user)
    create(:incident_management_oncall_schedule, project: project) do |schedule|
      create(:incident_management_oncall_rotation, schedule: schedule) do |rotation|
        create(:incident_management_oncall_participant, rotation: rotation, user: user)
      end
    end
  end
end
