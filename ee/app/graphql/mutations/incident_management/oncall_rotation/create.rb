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

        argument :schedule_iid, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The iid of the on-call schedule to create the on-call rotation in'

        argument :name, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'The name of the on-call rotation'

        argument :starts_at, Types::TimeType,
                 required: true,
                 description: 'The start date and time of the on-call rotation'

        argument :rotation_length, GraphQL::INT_TYPE,
                 required: true,
                 description: 'The rotation length of the on-call rotation'

        argument :rotation_length_unit, Types::IncidentManagement::OncallRotationLengthUnitEnum,
                 required: true,
                 description: 'The unit of the rotation length of the on-call rotation'

        argument :participant_usernames,
                 [GraphQL::STRING_TYPE],
                 required: true,
                 description: 'The usernames to participate in the on-call rotation.'

        def resolve(args)
          project = authorized_find!(full_path: args[:project_path])

          schedule = ::IncidentManagement::OncallSchedulesFinder.new(current_user, project, { iids: args[:schedule_iid] })
                                                                .execute
                                                                .first

          target_users = find_target_users(args[:participant_usernames])

          response ::IncidentManagement::OncallRotations::CreateService.new(
            schedule,
            project,
            current_user,
            args.slice(:name, :starts_at, :rotation_length, :rotation_length_unit),
            target_users
          ).execute
        end

        private

        def find_object(full_path:)
          resolve_project(full_path: full_path)
        end

        def find_target_users(assignee_usernames)
          UsersFinder.new(current_user, username: assignee_usernames).execute
        end
      end
    end
  end
end
