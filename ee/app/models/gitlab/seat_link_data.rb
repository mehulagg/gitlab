# frozen_string_literal: true

module Gitlab
  class SeatLinkData
    attr_reader :date, :key, :max_users, :active_users

    delegate :to_json, to: :data

    # All fields can be passed to initializer to override defaults. In some cases, the defaults
    # are preferable, like for SyncSeatLinkWorker, to determine seat link data, and in others,
    # like for SyncSeatLinkRequestWorker, the params are passed because the values from when
    # the job was enqueued are necessary.
    def initialize(date: default_date, key: default_key, max_users: nil, active_users: nil)
      @date = date
      @key = key
      @max_users = max_users || default_max_count(@date)
      @active_users = active_users || default_active_count(@date)
    end

    private

    def data
      {
        date: date.to_s,
        license_key: key,
        max_historical_user_count: max_users,
        active_users: active_users
      }
    end

    def default_date
      Time.current.utc.yesterday.to_date
    end

    def default_key
      ::License.current.data
    end

    def default_max_count(date)
      HistoricalData.max_historical_user_count(
        from: ::License.current.starts_at,
        to: date
      )
    end

    def default_active_count(date)
      HistoricalData.at(date)&.active_user_count
    end
  end
end
