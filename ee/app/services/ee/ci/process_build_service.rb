# frozen_string_literal: true
module EE
  module Ci
    module ProcessBuildService
      extend ::Gitlab::Utils::Override

      override :enqueue
      def enqueue(build)
        unless allowed_to_deploy?(build)
          return build.drop!(:protected_environment_failure)
        end

        super
      end

      private

      def allowed_to_deploy?(build)
        # We need to check if Protected Environments feature is available,
        # as evaluating `build.expanded_environment_name` is expensive.
        return true unless project.protected_environments_feature_available? # TODO:

        build.user.has_access_to_protected_environment?(build.persisted_environment)
      end
    end
  end
end
