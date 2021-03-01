# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module OncallRotation
      class Create < Base
        include ResolvesProject

        graphql_name 'OncallRotationCreate'

        argument :project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The project to create the on-call schedule in.'

        argument :schedule_iid, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'The IID of the on-call schedule to create the on-call rotation in.',
                 as: :iid

        argument :name, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'The name of the on-call rotation.'

        argument :starts_at, Types::IncidentManagement::OncallRotationDateInputType,
                 required: true,
                 description: 'The start date and time of the on-call rotation, in the timezone of the on-call schedule.'

        argument :ends_at, Types::IncidentManagement::OncallRotationDateInputType,
                 required: false,
                 description: 'The end date and time of the on-call rotation, in the timezone of the on-call schedule.'

        argument :rotation_length, Types::IncidentManagement::OncallRotationLengthInputType,
                 required: true,
                 description: 'The rotation length of the on-call rotation.'

        argument :active_period, Types::IncidentManagement::OncallRotationActivePeriodInputType,
                 required: false,
                 description: 'The active period of time that the on-call rotation should take place.'

        argument :participants,
                 [Types::IncidentManagement::OncallUserInputType],
                 required: true,
                 description: 'The usernames of users participating in the on-call rotation.'

        MAXIMUM_PARTICIPANTS = 100
        TIME_FORMAT = /^(0\d|1\d|2[0-3]):[0-5]\d$/.freeze

        def resolve(iid:, project_path:, participants:, **args)
          project = Project.find_by_full_path(project_path)

          raise_project_not_found unless project

          schedule = ::IncidentManagement::OncallSchedulesFinder.new(current_user, project, iid: iid)
                                                                .execute
                                                                .first

          raise_schedule_not_found unless schedule

          result = ::IncidentManagement::OncallRotations::CreateService.new(
            schedule,
            project,
            current_user,
            create_service_params(schedule, participants, args)
          ).execute

          response(result)

        rescue ActiveRecord::RecordInvalid => e
          raise Gitlab::Graphql::Errors::ArgumentError, e.message
        end

        private

        def create_service_params(schedule, participants, args)
          rotation_length = args[:rotation_length][:length]
          rotation_length_unit = args[:rotation_length][:unit]
          starts_at = parse_datetime(schedule, args[:starts_at])
          ends_at = parse_datetime(schedule, args[:ends_at]) if args[:ends_at]

          active_period_start, active_period_end = active_period_times(args)

          args.slice(:name).merge(
            length: rotation_length,
            length_unit: rotation_length_unit,
            starts_at: starts_at,
            ends_at: ends_at,
            participants: find_participants(participants),
            active_period_start: active_period_start,
            active_period_end: active_period_end
          )
        end

        def parse_datetime(schedule, timestamp)
          timestamp.asctime.in_time_zone(schedule.timezone)
        end

        def find_participants(user_array)
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
