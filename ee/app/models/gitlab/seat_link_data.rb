# frozen_string_literal: true

module Gitlab
  class SeatLinkData
    attr_reader :date, :key, :max_users, :active_users

    delegate :to_json, to: :data

    # All fields can be passed to initializer to override defaults. In some cases, the defaults
    # are preferable, like for SyncSeatLinkWorker, to determine seat link data, and in others,
    # like for SyncSeatLinkRequestWorker, the params are passed because the values from when
    # the job was enqueued are necessary.
    def initialize(date: nil, key: default_key, max_users: nil, active_users: nil)
      @date = date || historical_data&.recorded_at
      @key = key
      @max_users = max_users || default_max_count(@date)
      @active_users = active_users || default_active_count(@date)
    end

    # Returns true if historical data exists within the given date.
    def historical_data_exists?
      @historical_data.present?
    end

    private

    def data
      {
        date: date.iso8601,
        license_key: key,
        max_historical_user_count: max_users,
        active_users: active_users
      }
    end

    def default_key
      ::License.current.data
    end

    def license_starts_at
      ::License.current.starts_at.beginning_of_day
    end

    def default_max_count(timestamp)
      HistoricalData.max_historical_user_count(
        from: license_starts_at,
        to: timestamp
      )
    end

    def historical_data(timestamp = Time.current)
      @historical_data ||= HistoricalData.during(license_starts_at..timestamp).order(:recorded_at).last
    end

    def default_active_count(timestamp)
      historical_data(timestamp)&.active_user_count
    end
  end
end
