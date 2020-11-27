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
                 description: 'The iid of the on-call schedule to create the on-call rotation in'

        argument :name, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'The name of the on-call rotation'

        argument :starts_at, Types::IncidentManagement::OncallRotationDateInputType,
                 required: true,
                 description: 'The start date and time of the on-call rotation'

        argument :rotation_length, Types::IncidentManagement::OncallRotationLengthInputType,
                 required: true,
                 description: 'The rotation length of the on-call rotation'

        argument :participant_usernames,
                 [GraphQL::STRING_TYPE],
                 required: true,
                 description: 'The usernames to participate in the on-call rotation.'

        def resolve(args)
          project = authorized_find!(full_path: args[:project_path])

          schedule = ::IncidentManagement::OncallSchedulesFinder.new(current_user, project, { iids: args[:schedule_iid] })
                                                                .execute
                                                                .first

          params = prepare_params(args, schedule)

          result = ::IncidentManagement::OncallRotations::CreateService.new(
            schedule,
            project,
            current_user,
            params
          ).execute

          errors = result.error? ? [result.message] : []

          {
            oncall_rotation: result.payload[:oncall_rotation],
            errors: errors
          }
        end

        private

        def prepare_params(args, schedule)
          participants = find_participants(args[:participant_usernames])
          rotation_length = args[:rotation_length][:length]
          rotation_length_unit = args[:rotation_length][:unit]
          starts_at = parse_start_time(schedule, args)

          args.slice(:name).merge(
            rotation_length: rotation_length,
            rotation_length_unit: rotation_length_unit,
            starts_at: starts_at,
            participants: participants
          )
        end

        def parse_start_time(schedule, args)
          "#{args[:starts_at][:date]} #{args[:starts_at][:time]}".in_time_zone(schedule.timezone)
        end

        def find_object(full_path:)
          resolve_project(full_path: full_path)
        end

        def find_participants(usernames)
          UsersFinder.new(current_user, username: usernames).execute
        end
      end
    end
  end
end
