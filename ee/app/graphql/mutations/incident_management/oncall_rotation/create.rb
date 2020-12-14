# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module OncallRotation
      class Create < Base
        include ResolvesProject

        graphql_name 'OncallRotationCreate'

        argument :project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The project to create the on-call schedule in'

        argument :schedule_iid, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'The iid of the on-call schedule to create the on-call rotation in',
                 as: :iid

        argument :name, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'The name of the on-call rotation'

        argument :starts_at, Types::IncidentManagement::OncallRotationDateInputType,
                 required: true,
                 description: 'The start date and time of the on-call rotation, in the timezone of the on-call schedule'

        argument :rotation_length, Types::IncidentManagement::OncallRotationLengthInputType,
                 required: true,
                 description: 'The rotation length of the on-call rotation'

        argument :participants,
                 [Types::IncidentManagement::OncallUserInputType],
                 required: true,
                 description: 'The usernames of users participating in the on-call rotation'

        MAXIMUM_PARTICIPANTS = 100

        def resolve(iid:, project_path:, participants:, **args)
          project = Project.find_by_full_path(project_path)

          schedule = ::IncidentManagement::OncallSchedulesFinder.new(current_user, project, iid: iid)
                                                                .execute
                                                                .first

          raise_schedule_not_found unless schedule

          begin
            result = ::IncidentManagement::OncallRotations::CreateService.new(
              schedule,
              project,
              current_user,
              create_service_params(schedule, participants, args)
            ).execute

          rescue ActiveRecord::RecordInvalid => e
            raise Gitlab::Graphql::Errors::ArgumentError, e.message
          end

          response(result)
        end

        private

        def create_service_params(schedule, participants, args)
          rotation_length = args[:rotation_length][:length]
          rotation_length_unit = args[:rotation_length][:unit]
          starts_at = parse_start_time(schedule, args)

          args.slice(:name).merge(
            length: rotation_length,
            length_unit: rotation_length_unit,
            starts_at: starts_at,
            participants: find_participants(participants)
          )
        end

        def parse_start_time(schedule, args)
          args[:starts_at].asctime.in_time_zone(schedule.timezone)
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
          raise Gitlab::Graphql::Errors::ArgumentError, 'A username that was provided could not be matched to a user'
        end
      end
    end
  end
end
