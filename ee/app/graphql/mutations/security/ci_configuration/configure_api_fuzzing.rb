# frozen_string_literal: true

module Mutations
  module Security
    module CiConfiguration
      class ConfigureApiFuzzing < BaseMutation
        include FindsProject

        graphql_name 'ConfigureApiFuzzing'

        argument :configuration, ::Types::CiConfiguration::ApiFuzzing::InputType,
          required: true,
          description: 'API Fuzzing CI configuration for the project.'

        field :status, GraphQL::STRING_TYPE, null: false,
          description: ''

        field :configuration_yaml, GraphQL::STRING_TYPE, null: true,
          description: ''

        field :gitlab_ci_yaml_edit_url, GraphQL::STRING_TYPE, null: true,
          description: ''

        def resolve(configuration:)
          project = authorized_find!(configuration[:project_path])

          result = ::Security::CiConfiguration::SastCreateService.new(project, current_user, configuration).execute
          prepare_response(result)
        end

        private

        def prepare_response(result)
          {
            status: result[:status],
            success_path: result[:success_path],
            errors: Array(result[:errors])
          }
        end
      end
    end
  end
end
