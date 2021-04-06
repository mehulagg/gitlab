# frozen_string_literal: true
module EE
  module Ci
    module ProcessBuildService
      extend ::Gitlab::Utils::Override

      override :enqueue
      def enqueue(build)
        if protected_environment?(build)
          return build.drop!(:protected_environment_failure)
        end

        super
      end

      private

      def protected_environment?(build)
        return false unless build.has_environment?

        # Initializing an object than fetching a persisted row in order to avoid N+1.
        # See https://gitlab.com/gitlab-org/gitlab/-/issues/326445
        ::Environment.new(project: build.project, name: build.expanded_environment_name)
                     .protected_from?(build.user)
      end
    end
  end
end
