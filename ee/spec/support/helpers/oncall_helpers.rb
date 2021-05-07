# frozen_string_literal: true

module OncallHelpers
  def active_period_for_date_with_tz(date, rotation)
    date = date.in_time_zone(rotation.schedule.timezone)

    rotation.active_period.for_date(date)
  end
end
