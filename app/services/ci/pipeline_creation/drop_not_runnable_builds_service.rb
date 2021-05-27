# frozen_string_literal: true

module Ci
  module PipelineCreation
    class DropNotRunnableBuildsService
      include Gitlab::Utils::StrongMemoize

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

        validate_build_matchers
      end

      private

      attr_reader :pipeline
      delegate :project, to: :pipeline

      def runner_matchers
        @runner_matchers ||= project.all_available_runner_matchers
      end

      def validate_build_matchers
        pipeline.build_matchers.each do |build_matcher|
          failure_reason = validate_build_matcher(build_matcher)
          next unless failure_reason

          drop_all_builds(build_matcher.build_ids, failure_reason)
        end
      end

      def validate_build_matcher(build_matcher)
        return if matching_any_runner?(build_matcher)

        build_matcher.not_matched_failure_reason
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

      def matching_any_runner?(build_matcher)
        runner_matchers.any? { |matcher| matcher.full_match?(build_matcher) }
      end
    end
  end
end

Ci::PipelineCreation::DropNotRunnableBuildsService.prepend_mod_with('Ci::PipelineCreation::DropNotRunnableBuildsService')
