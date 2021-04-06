# frozen_string_literal: true

module Gitlab
  module Ci
    module Authorization
      # This is the SSOT facility to authorize the users access to environments.
      class ProtectedEnvironment
        attr_reader :user

        def initialize(user)
          @user = user
        end

        def can_access_to?(environment, project: nil)
          if environment.is_a?(String)
            raise ArgumentError, 'Environment name must be combined with the project' unless project.present?

            return true unless project.protected_environments_feature_available?

            project.protected_environment_accessible_to?(environment, user)
          elsif environment.is_a?(Environment)
            # TODO:
          end
        end

        private
      end
    end
  end
end
