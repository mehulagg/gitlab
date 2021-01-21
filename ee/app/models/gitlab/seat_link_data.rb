# frozen_string_literal: true

module Gitlab
  class SeatLinkData
    include Gitlab::Utils::StrongMemoize

    attr_reader :timestamp, :key, :max_users, :active_users

    delegate :to_json, to: :data

    # All fields can be passed to initializer to override defaults. In some cases, the defaults
    # are preferable, like for SyncSeatLinkWorker, to determine seat link data, and in others,
    # like for SyncSeatLinkRequestWorker, the params are passed because the values from when
    # the job was enqueued are necessary.
    def initialize(timestamp: nil, key: default_key, max_users: nil, active_users: nil)
      @timestamp = timestamp || historical_data&.recorded_at
      @key = key
      @max_users = max_users || default_max_count
      @active_users = active_users || default_active_count
    end

    # Returns true if historical data exists between license start and the given date.
    def historical_data_exists?
      historical_data.present?
    end

    private

    def data
      {
        timestamp: timestamp&.iso8601,
        date: timestamp&.to_date&.to_s,
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

    def default_max_count
      HistoricalData.max_historical_user_count(
        from: license_starts_at,
        to: timestamp
      )
    end

    def historical_data
      strong_memoize(:historical_data) do
        to_timestamp = timestamp || Time.current
        HistoricalData.during(license_starts_at..to_timestamp).order(:recorded_at).last
      end
    end

    def default_active_count
      historical_data&.active_user_count
    end
  end
end
