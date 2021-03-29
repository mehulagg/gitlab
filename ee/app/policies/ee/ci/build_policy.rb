# frozen_string_literal: true
module EE
  module Ci
    module BuildPolicy
      extend ActiveSupport::Concern

      prepended do
        condition(:deployable_by_user) { deployable_by_user? }
        condition(:protected_environment_access) { deployable_by_user? }

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
          ::Gitlab::Access::EnvironmentProtection
            .new(user: user).has_access_to?(build.persisted_environment)
        end
      end
    end
  end
end
