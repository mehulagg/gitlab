# frozen_string_literal: true
module EE
  module Ci
    module ProcessBuildService
      extend ::Gitlab::Utils::Override

      override :enqueue
      def enqueue(build)
        if build.instantized_environment&.protected_from?(build.user)
          return build.drop!(:protected_environment_failure)
        end

        super
      end
    end
  end
end
