# frozen_string_literal: true

module Ci
  module PipelineCreation
    class DropNotRunnableBuildsService
      include ::Gitlab::Utils::StrongMemoize

      def initialize(pipeline)
        @pipeline = pipeline
      end

      def execute
        return unless ::Feature.enabled?(:ci_drop_new_builds_when_ci_quota_exceeded, project, default_enabled: :yaml)
        return unless pipeline.created?
        return unless project.shared_runners_enabled?

        validate_build_matchers
      end

      private

      attr_reader :pipeline
      delegate :project, to: :pipeline

      def validate_build_matchers
        pipeline.build_matchers.each do |build_matcher|
          next if matching_any_runner?(build_matcher)

          drop_all_builds(build_matcher.build_ids, :ci_quota_exceeded)
        end
      end

      def matching_any_runner?(build_matcher)
        runner_matchers.any? do |matcher|
          matcher.matches?(build_matcher) &&
            matcher.matches_quota?(build_matcher)
        end
      end

      def runner_matchers
        strong_memoize(:runner_matchers) do
          project.all_runners.active.online.runner_matchers
        end
      end

      ##
      # We skip pipeline processing until we drop all required builds. Otherwise
      # as we drop the first build, the remaining builds to be dropped could
      # transition to other states by `PipelineProcessWorker` running async.
      #
      def drop_all_builds(build_ids, failure_reason)
        pipeline.builds.id_in(build_ids).each do |build|
          build.drop(failure_reason, skip_pipeline_processing: true)
        end
      end
    end
  end
end
