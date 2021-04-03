# frozen_string_literal: true

module Geo
  class CreateObjectPoolService
    include ExclusiveLeaseGuard
    include Gitlab::Geo::LogHelpers

    LEASE_TIMEOUT    = 1.hour.freeze
    LEASE_KEY_PREFIX = 'object_pool:create'

    attr_reader :pool_repository

    def initialize(pool_repository)
      @pool_repository = pool_repository
    end

    def execute
      try_obtain_lease do
        log_info("Creating object pool for pool_#{pool_repository.id}")
        pool_repository.create_object_pool
      end
    end

    def lease_key
      @lease_key ||= "#{LEASE_KEY_PREFIX}:#{pool_repository.id}"
    end

    def lease_timeout
      LEASE_TIMEOUT
    end
  end
end
