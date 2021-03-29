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
        ::Gitlab::Access::EnvironmentProtection
          .new(user: build.user).has_access_to?(build.persisted_environment)
      end
    end
  end
end
