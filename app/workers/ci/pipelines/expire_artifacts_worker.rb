# frozen_string_literal: true

module Ci
  module Pipelines
    class ExpireArtifactsWorker
      include ApplicationWorker
      # rubocop:disable Scalability/CronWorkerContext
      # This worker does not perform work scoped to a context
      include CronjobQueue
      # rubocop:enable Scalability/CronWorkerContext

      deduplicate :until_executed, including_scheduled: true
      idempotent!
      feature_category :continuous_integration

      def perform
        if ::Feature.enabled?(:ci_split_pipeline_artifacts_removal)
          ::Ci::Pipelines::DestroyExpiredArtifactsService.new.execute
        end
      end
    end
  end
end
