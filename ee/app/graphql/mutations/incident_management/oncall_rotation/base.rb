# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module OncallRotation
      class Base < BaseMutation
        MAXIMUM_PARTICIPANTS = 100
        TIME_FORMAT = /^(0\d|1\d|2[0-3]):[0-5]\d$/.freeze

        field :oncall_rotation,
              ::Types::IncidentManagement::OncallRotationType,
              null: true,
              description: 'The on-call rotation.'

        authorize :admin_incident_management_oncall_schedule

        private

        def response(result)
          {
            oncall_rotation: result.payload[:oncall_rotation],
            errors: result.errors
          }
        end

        def find_object(project_path:, schedule_iid:, **args)
          project = Project.find_by_full_path(project_path)

          return unless project

          schedule = ::IncidentManagement::OncallSchedulesFinder.new(current_user, project, iid: schedule_iid).execute.first

          return unless schedule

          args = args.merge(id: args[:id].model_id)

          ::IncidentManagement::OncallRotationsFinder.new(current_user, project, schedule, args).execute.first
        end

        def parsed_params(schedule, participants, args)
          rotation_length = args.dig(:rotation_length, :length)
          rotation_length_unit = args.dig(:rotation_length, :unit)
          starts_at = parse_datetime(schedule, args[:starts_at])
          ends_at = parse_datetime(schedule, args[:ends_at]) if args[:ends_at]

          active_period_start, active_period_end = active_period_times(args)

          {
            length: rotation_length,
            length_unit: rotation_length_unit,
            starts_at: starts_at,
            ends_at: ends_at,
            participants: find_participants(participants),
            active_period_start: active_period_start,
            active_period_end: active_period_end
          }
        end

        def parse_datetime(schedule, timestamp)
          timestamp&.asctime&.in_time_zone(schedule.timezone)
        end

        def find_participants(user_array)
          return if user_array.nil?
          return [] if user_array == []

          raise_too_many_users_error if user_array.size > MAXIMUM_PARTICIPANTS

          usernames = user_array.map {|h| h[:username] }
          raise_duplicate_users_error if usernames.size != usernames.uniq.size

          matched_users = UsersFinder.new(current_user, username: usernames).execute.order_by(:username)
          raise_user_not_found if matched_users.size != user_array.size

          user_array = user_array.sort_by! { |h| h[:username] }

          user_array.map.with_index { |param, i| param.to_h.merge(user: matched_users[i]) }
        end

        def active_period_times(args)
          active_period_args = args.dig(:active_period)

          return [nil, nil] if active_period_args.blank?

          start_time = active_period_args[:start_time]
          end_time = active_period_args[:end_time]

          raise invalid_time_error unless TIME_FORMAT.match?(start_time)
          raise invalid_time_error unless TIME_FORMAT.match?(end_time)

          # We parse the times into dates to compare.
          # Time.parse parses a timestamp into a Time with todays date
          # Time.parse("22:11") => 2021-02-23 22:11:00 +0000
          parsed_from = Time.parse(start_time)
          parsed_to = Time.parse(end_time)

          # Overnight shift times will be supported via
          # https://gitlab.com/gitlab-org/gitlab/-/issues/322079
          if parsed_to < parsed_from
            raise ::Gitlab::Graphql::Errors::ArgumentError, "'start_time' time must be before 'end_time' time"
          end

          [start_time, end_time]
        end

        def raise_project_not_found
          raise Gitlab::Graphql::Errors::ArgumentError, 'The project could not be found'
        end

        def raise_schedule_not_found
          raise Gitlab::Graphql::Errors::ArgumentError, 'The schedule could not be found'
        end

        def raise_too_many_users_error
          raise Gitlab::Graphql::Errors::ArgumentError, "A maximum of #{MAXIMUM_PARTICIPANTS} participants can be added"
        end

        def raise_duplicate_users_error
          raise Gitlab::Graphql::Errors::ArgumentError, "A duplicate username is included in the participant list"
        end

        def raise_user_not_found
          raise Gitlab::Graphql::Errors::ArgumentError, "A provided username couldn't be matched to a user"
        end

        def invalid_time_error
          ::Gitlab::Graphql::Errors::ArgumentError.new 'Time given is invalid'
        end
      end
    end
  end
end
