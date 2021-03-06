# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module OncallSchedule
      class Create < OncallScheduleBase
        include FindsProject

        graphql_name 'OncallScheduleCreate'

        argument :project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The project to create the on-call schedule in.'

        argument :name, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'The name of the on-call schedule.'

        argument :description, GraphQL::STRING_TYPE,
                 required: false,
                 description: 'The description of the on-call schedule.'

        argument :timezone, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'The timezone of the on-call schedule.'

        def resolve(args)
          project = authorized_find!(args[:project_path])

          response ::IncidentManagement::OncallSchedules::CreateService.new(
            project,
            current_user,
            args.slice(:name, :description, :timezone)
          ).execute
        end
      end
    end
  end
end
