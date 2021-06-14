# frozen_string_literal: true

module Ci
  module PipelineCreation
    class DropNotRunnableBuildsService
      include ::Gitlab::Utils::StrongMemoize

      def initialize(pipeline)
        @pipeline = pipeline
      end

      ##
      # We want to run this service exactly once,
      # before the first pipeline processing call
      #
      def execute
        return unless ::Feature.enabled?(:ci_drop_new_builds_when_ci_quota_exceeded, project, default_enabled: :yaml)
        return unless pipeline.created?
        return unless project.shared_runners_enabled?
        return unless project.ci_minutes_quota.minutes_used_up?

        validate_build_matchers
      end

      private

      attr_reader :pipeline
      delegate :project, to: :pipeline

      def validate_build_matchers
        build_ids = pipeline
          .build_matchers
          .filter_map { |matcher| matcher.build_ids if should_drop?(matcher) }
          .flatten

        drop_all_builds(build_ids, :ci_quota_exceeded)
      end

      def should_drop?(build_matcher)
        matches_instance_runners_and_quota_used_up?(build_matcher) &&
          !matches_private_runners?(build_matcher)
      end

      def matches_instance_runners_and_quota_used_up?(build_matcher)
        instance_runners.any? do |matcher|
          matcher.matches?(build_matcher) &&
            !matcher.matches_quota?(build_matcher)
        end
      end

      def matches_private_runners?(build_matcher)
        private_runners.any? { |matcher| matcher.matches?(build_matcher) }
      end

      def instance_runners
        strong_memoize(:instance_runners) do
          runner_matchers.select(&:instance_type?)
        end
      end

      def private_runners
        strong_memoize(:private_runners) do
          runner_matchers.reject(&:instance_type?)
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
        return if build_ids.empty?

        pipeline.builds.id_in(build_ids).each do |build|
          build.drop!(failure_reason, skip_pipeline_processing: true)
        end
      end
    end
  end
end
