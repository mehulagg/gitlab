# frozen_string_literal: true

module Ci
  class TriggerDownstreamSubscriptionsWorker # rubocop:disable Scalability/IdempotentWorker
    include ::ApplicationWorker
    include ::PipelineQueue

    worker_resource_boundary :cpu

    def perform(pipeline_id)
      ::Ci::Pipeline.find_by_id(pipeline_id).try do |pipeline|
        ::Ci::TriggerDownstreamSubscriptionService
          .new(pipeline.project, pipeline.user)
          .execute(pipeline)
      end
    end
  end
end
