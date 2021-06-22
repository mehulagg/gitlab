# frozen_string_literal: true

module Ci
  module StuckBuilds
    class DropPendingWorker
      include ApplicationWorker

      sidekiq_options retry: 3

      feature_category :continuous_integration

      idempotent!

      EXCLUSIVE_LEASE_KEY = 'ci_stuck_builds_drop_pending_worker_lease'

      def perform
        return unless try_obtain_lease

        ::Ci::StuckBuilds::DropPendingService.new.execute

        remove_lease
      end

      def try_obtain_lease
        @uuid = Gitlab::ExclusiveLease.new(EXCLUSIVE_LEASE_KEY, timeout: 30.minutes).try_obtain
      end

      def remove_lease
        Gitlab::ExclusiveLease.cancel(EXCLUSIVE_LEASE_KEY, @uuid)
      end
    end
  end
end
