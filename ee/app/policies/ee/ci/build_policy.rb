# frozen_string_literal: true
module EE
  module Ci
    module BuildPolicy
      extend ActiveSupport::Concern

      prepended do
        # overriding
        condition(:protected_environment) { !has_access_to_protected_environment? }

        def has_access_to_protected_environment?
          Gitlab::Ci::Authorization::ProtectedEnvironment
            .new(user)
            .can_access_to?(build.expanded_environment_name, project: build.project)
        end
      end
    end
  end
end
