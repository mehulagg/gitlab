# frozen_string_literal: true

module Mutations
  module Ci
    module RunnersRegistrationToken
      class Reset < BaseMutation
        graphql_name 'RunnersRegistrationTokenReset'

        authorize :reset_runners_registration_token

        argument :full_path, GraphQL::ID_TYPE,
          required: false,
          description: 'Full path of the project or group to reset the token for. Omit if resetting instance runner token.'

        field :token,
          GraphQL::STRING_TYPE,
          null: true,
          description: 'The runner token after mutation.'

        def resolve(**args)
          full_path = args[:full_path]
          scope = full_path.blank? ? :global : authorized_find!(full_path: full_path)

          if scope == :global
            authorize!(scope)

            ApplicationSetting.current.reset_runners_registration_token!

            token = ApplicationSetting.current.runners_registration_token
          else
            scope.reset_runners_token!
            token = scope.runners_token
          end

          {
            token: token,
            errors: []
          }
        end

        private

        def find_object(full_path:)
          return unless full_path

          GitlabSchema.object_from_id(full_path, expected_type: [::Project, ::Group])
        end
      end
    end
  end
end
