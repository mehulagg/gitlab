# frozen_string_literal: true

module PersonalAccessTokens
  module Groups
    class UpdateLifetimeService < PersonalAccessTokens::Instance::UpdateLifetimeService
      extend ::Gitlab::Utils::Override

      def initialize(group)
        @group = group
      end

      private

      attr_reader :group

      override :perform
      def perform
        ::PersonalAccessTokens::Groups::PolicyWorker.perform_in(DEFAULT_LEASE_TIMEOUT, group.id)
      end

      # Used by ExclusiveLeaseGuard
      # This should be unique per group
      override :lease_key
      def lease_key
        "#{super}:group_id:#{group.id}"
      end
    end
  end
end
