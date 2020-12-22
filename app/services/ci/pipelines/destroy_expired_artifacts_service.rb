# frozen_string_literal: true

module Ci
  module Pipelines
    class DestroyExpiredArtifactsService
      include ::Gitlab::LoopHelpers
      include ::Gitlab::Utils::StrongMemoize

      BATCH_SIZE = 100
      LOOP_TIMEOUT = 5.minutes
      LOOP_LIMIT = 1000

      def execute
        loop_until(timeout: LOOP_TIMEOUT, limit: LOOP_LIMIT) do
          destroy_artifacts_batch
        end
      end

      private

      def destroy_artifacts_batch
        artifacts = Ci::PipelineArtifact.expired(BATCH_SIZE).to_a
        return false if artifacts.empty?

        artifacts.each(&:destroy!)
        destroyed_artifacts_counter.increment({}, artifacts.size)

        true
      end

      def destroyed_artifacts_counter
        strong_memoize(:destroyed_artifacts_counter) do
          name = :destroyed_pipeline_artifacts_count_total
          comment = 'Counter of destroyed expired pipeline artifacts'

          ::Gitlab::Metrics.counter(name, comment)
        end
      end
    end
  end
end
