# frozen_string_literal: true

module EE
  module Ci
    # RegisterJobService EE mixin
    #
    # This module is intended to encapsulate EE-specific service logic
    # and be included in the `RegisterJobService` service
    module RegisterJobService
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      override :pre_assign_runner_checks
      def pre_assign_runner_checks
        super.merge({
          secrets_provider_not_found: -> (build, _) { build.ci_secrets_management_available? && build.secrets? && !build.secrets_provider? }
        })
      end
    end
  end
end
