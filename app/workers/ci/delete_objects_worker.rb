# frozen_string_literal: true

module Ci
  class DeleteObjectsWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include LimitedCapacity::Worker

    feature_category :continuous_integration
    idempotent!

    def perform_work(*args)
      service.execute
    end

    def remaining_work
      service.remaining_count(limit: remaining_capacity)
    end

    def max_running_jobs
      if ::Feature.enabled?(:ci_delete_objects_low_concurrency)
        2
      elsif ::Feature.enabled?(:ci_delete_objects_medium_concurrency)
        50
      elsif ::Feature.enabled?(:ci_delete_objects_high_concurrency)
        200
      else
        0
      end
    end

    private

    def service
      @service ||= DeleteObjectsService.new
    end
  end
end
