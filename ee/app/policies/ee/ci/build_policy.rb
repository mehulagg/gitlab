# frozen_string_literal: true
module EE
  module Ci
    module BuildPolicy
      extend ActiveSupport::Concern

      prepended do
        condition(:deployable_by_user) { deployable_by_user? }

        condition(:protected_environment_access) do
          project = @subject.project
          environment = @subject.environment

          if environment && project.protected_environments_feature_available?
            protected_environment = project.protected_environment_by_name(environment)

            !!protected_environment&.accessible_to?(user)
          else
            false
          end
        end

        rule { ~deployable_by_user & ~protected_environment_access}.policy do
          prevent :update_build
        end

        rule { protected_environment_access }.policy do
          enable :update_commit_status
          enable :update_build
        end

        private

        alias_method :current_user, :user
        alias_method :build, :subject

        def deployable_by_user?
          # We need to check if Protected Environments feature is available,
          # and whether there is an environment defined for the current build,
          # as evaluating `build.expanded_environment_name` is expensive.
          return true unless build.has_environment?
          return true unless build.project.protected_environments_feature_available?

          build.project.protected_environment_accessible_to?(build.expanded_environment_name, user)
        end
      end
    end
  end
end
