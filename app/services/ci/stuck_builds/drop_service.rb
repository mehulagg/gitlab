# frozen_string_literal: true

module Ci
  module StuckBuilds
    class DropService
      def execute
        Gitlab::AppLogger.info "#{self.class}: Cleaning stuck builds"

        ::Ci::StuckBuilds::DropRunningWorker.new.perform
        ::Ci::StuckBuilds::DropScheduledWorker.new.perform
        ::Ci::StuckBuilds::DropPendingWorker.new.perform
      end
    end
  end
end
