# frozen_string_literal: true

module Mutations
  module Security
    module CiConfiguration
      class ConfigureSecurityAnalyzer < BaseMutation
        argument :project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'Full path of the project.'

        field :success_path, GraphQL::STRING_TYPE, null: true,
              description: 'Redirect path to use when the response is successful.'

        field :branch, GraphQL::STRING_TYPE, null: true,
              description: 'Branch that has the new/modified `.gitlab-ci.yml` file.'

        authorize :push_code

        def resolve(project_path:)
          project = authorized_find!(project_path)

          result = yield(project)
          prepare_response(result)
        end

        private

        def prepare_response(result)
          {
            branch: result.payload[:branch],
            success_path: result.payload[:success_path],
            errors: result.errors
          }
        end
      end
    end
  end
end
