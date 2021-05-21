# frozen_string_literal: true
module EE
  module Ci
    module BuildPolicy
      extend ActiveSupport::Concern

      prepended do
        # overriding
        condition(:protected_environment) do
          @subject.persisted_environment.try(:protected_from?, user)
        end

        condition(:reporter_has_access_to_protected_environment) do
          @subject.persisted_environment.try(:protected_by?, user) &&
            can?(:reporter_access, @subject.project)
        end

        # If a reporter has an access to the protected environment,
        # the user can jailbreak from the fundamental CI permissions and execute the deployment job.
        # See https://gitlab.com/gitlab-org/gitlab/-/issues/225482
        rule { reporter_has_access_to_protected_environment }.policy do
          enable :jailbreak
          enable :update_commit_status
          enable :update_build
        end
      end
    end
  end
end
