# frozen_string_literal: true
module EE
  module Ci
    module BuildPolicy
      extend ActiveSupport::Concern

      prepended do
        # overriding
        condition(:protected_environment) do
          @subject.has_environment? &&
          # Initializing an object than fetching a persisted row in order to avoid N+1.
          # See https://gitlab.com/gitlab-org/gitlab/-/issues/326445
          ::Environment.new(project: subject.project, name: subject.expanded_environment_name)
                       .protected_from?(user)
        end

        # overriding
        condition(:reporter_has_access_to_protected_environment) do
          @subject.has_environment? &&
          can?(:reporter_access, @subject.project) &&
          # Initializing an object than fetching a persisted row in order to avoid N+1.
          # See https://gitlab.com/gitlab-org/gitlab/-/issues/326445
          ::Environment.new(project: subject.project, name: subject.expanded_environment_name)
                       .protected_by?(user)
        end
      end
    end
  end
end
