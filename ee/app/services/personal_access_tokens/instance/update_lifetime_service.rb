# frozen_string_literal: true

module PersonalAccessTokens
  module Instance
    class UpdateLifetimeService
      include ExclusiveLeaseGuard

      DEFAULT_LEASE_TIMEOUT = 3.hours.to_i

      def execute
        try_obtain_lease do
          perform
        end
      end

      private

      def perform
        ::PersonalAccessTokens::Instance::PolicyWorker.perform_in(DEFAULT_LEASE_TIMEOUT)
      end

      # Used by ExclusiveLeaseGuard
      def lease_timeout
        DEFAULT_LEASE_TIMEOUT
      end

      # Used by ExclusiveLeaseGuard
      # Overriding value as we never release the lease
      # before the timeout in order to prevent multiple
      # PersonalAccessTokens::Instance::PolicyWorker to start in
      # a short span of time
      def lease_release?
        false
      end
    end
  end
end
