# frozen_string_literal: true

module Ci
  module StuckBuilds
    class DropPendingService
      include ServiceHelpers

      BUILD_PENDING_OUTDATED_TIMEOUT = 1.day
      BUILD_PENDING_STUCK_TIMEOUT = 1.hour
      BUILD_LOOKBACK = 5.days

      def execute
        drop(
          Ci::Build.pending.updated_before(lookback: BUILD_LOOKBACK.ago, timeout: BUILD_PENDING_OUTDATED_TIMEOUT.ago),
          failure_reason: :stuck_or_timeout_failure
        )

        drop_stuck(
          Ci::Build.pending.updated_before(lookback: BUILD_LOOKBACK.ago, timeout: BUILD_PENDING_STUCK_TIMEOUT.ago),
          failure_reason: :stuck_or_timeout_failure
        )
      end
    end
  end
end
