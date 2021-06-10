# frozen_string_literal: true

module Mutations
  module Ci
    module RunnersRegistrationToken
      class Reset < BaseMutation
        graphql_name 'RunnersRegistrationTokenReset'

        authorize :update_runners_registration_token

        argument :full_path, GraphQL::ID_TYPE,
          required: false,
          description: 'Full path of the project or group to reset the token for. Omit if resetting instance runner token.'

        field :token,
          GraphQL::STRING_TYPE,
          null: true,
          description: 'The runner token after mutation.'

        def resolve(**args)
          {
            token: reset_token(args[:full_path]),
            errors: []
          }
        end

        private

        def find_object(full_path:)
          return unless full_path

          GitlabSchema.object_from_id(full_path, expected_type: [::Project, ::Group])
        end

        def reset_token(full_path)
          if full_path.blank?
            authorize!(:global)

            ApplicationSetting.current.reset_runners_registration_token!
            ApplicationSetting.current_without_cache.runners_registration_token
          else
            project_or_group = authorized_find!(full_path: full_path)
            project_or_group.reset_runners_token!
            project_or_group.runners_token
          end
        end
      end
    end
  end
end
