# frozen_string_literal: true

class HistoricalData < ApplicationRecord
  validates :recorded_at, presence: true

  # HistoricalData.during((Time.current - 1.year)..Time.current).average(:active_user_count)
  scope :during, ->(range) { where(recorded_at: range) }
  # HistoricalData.up_until(Time.current - 1.month).average(:active_user_count)
  scope :up_until, ->(timestamp) { where("recorded_at <= :timestamp", timestamp: timestamp) }

  class << self
    def track!
      create!(
        recorded_at:        Time.current,
        active_user_count:  License.load_license&.current_active_users_count
      )
    end

    # HistoricalData.at(Date.new(2014, 1, 1)).active_user_count
    def at(date)
      find_by(recorded_at: date.all_day)
    end

    def max_historical_user_count(license: nil, from: nil, to: nil)
      license ||= License.current
      expires_at = license&.expires_at || Time.current
      from ||= (expires_at - 1.year).beginning_of_day
      to   ||= expires_at.end_of_day

      HistoricalData.during(from..to).maximum(:active_user_count) || 0
    end

    def in_license_term(license)
      start_date = license.starts_at.beginning_of_day
      expiration_date = license.expires_at&.end_of_day || Time.current

      HistoricalData.during(start_date..expiration_date)
    end
  end
end
