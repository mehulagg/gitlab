# frozen_string_literal: true

module Resolvers
  class TimelogResolver < BaseResolver
    include LooksAhead

    type ::Types::TimelogType.connection_type, null: false

    argument :start_date, Types::TimeType,
              required: false,
              description: 'List time logs within a date range where the logged date is equal to or after startDate.'

    argument :end_date, Types::TimeType,
              required: false,
              description: 'List time logs within a date range where the logged date is equal to or before endDate.'

    argument :start_time, Types::TimeType,
              required: false,
              description: 'List time-logs within a time range where the logged time is equal to or after startTime.'

    argument :end_time, Types::TimeType,
              required: false,
              description: 'List time-logs within a time range where the logged time is equal to or before endTime.'

    def resolve_with_lookahead(**args)
      validate_args!(args)
      validate_duplicated_args!(args)
      transformed_args = transform_args(args)
      validate_time_difference!(transformed_args)

      find_timelogs(transformed_args)
    end

    private

    def preloads
      {
        note: [:note]
      }
    end

    def find_timelogs(args)
      timelogs = Timelog.in_group(object)

      timelogs =
        if args.key?(:start_time) && args.key?(:end_time)
          timelogs.between_times(args[:start_time], args[:end_time])
        elsif args.key?(:start_time)
          timelogs.after(args[:start_time])
        elsif args.key?(:end_time)
          timelogs.before(args[:end_time])
        else
          timelogs
        end

      apply_lookahead(timelogs)
    end

    def validate_args!(args)
      raise_argument_error('Both date and time arguments must not be present') if
        args.key?(:start_time) && args.key?(:start_date) ||
        args.key?(:end_time) && args.key?(:end_date)
    end

    def validate_time_difference!(args)
      raise_argument_error('Start argument must be before End argument') if
        args[:start_time] &&
        args[:end_time] &&
        args[:end_time] < args[:start_time]
    end

    def transform_args(args)
      return args if args.keys == [:start_time, :end_time]

      time_args = args.except(:start_date, :end_date)

      time_args[:start_time] = args[:start_date].beginning_of_day if args[:start_date]
      time_args[:end_time] = args[:end_date].end_of_day if args[:end_date]

      time_args
    end

    def validate_duplicated_args!(args)
      if args.key?(:start_time) && args.key?(:start_date) ||
        args.key?(:end_time) && args.key?(:end_date)
        raise_argument_error('Both date and time arguments must not be present')
      end
    end

    def raise_argument_error(message)
      raise Gitlab::Graphql::Errors::ArgumentError, message
    end
  end
end
