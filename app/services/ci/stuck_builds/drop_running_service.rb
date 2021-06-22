# frozen_string_literal: true

module Ci
  module StuckBuilds
    class DropRunningService
      include ServiceHelpers

      BUILD_RUNNING_OUTDATED_TIMEOUT = 1.hour

      def execute
        Gitlab::AppLogger.info "#{self.class}: Cleaning running stuck builds"

        drop(running_timed_out_builds, failure_reason: :stuck_or_timeout_failure)
      end

      def running_timed_out_builds
        Ci::Build.running.where( # rubocop: disable CodeReuse/ActiveRecord
          'ci_builds.updated_at < ?',
          BUILD_RUNNING_OUTDATED_TIMEOUT.ago
        )
      end
    end
  end
end
