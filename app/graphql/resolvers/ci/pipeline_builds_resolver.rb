# frozen_string_literal: true

module Resolvers
  module Ci
    class PipelineBuildsResolver < CachingArrayResolver
      alias_method :pipeline, :object

      def cache_key(status: nil)
        [pipeline, status]
      end

      def model_class
        ::Ci::Build
      end

      def query_for(key)
        pipeline_builds(key.first, key.second)
      end

      def store(key, build)
        pipeline = key.first
        # Prevent lookups for values we already know
        build.pipeline = pipeline
        build.project = pipeline.project
        super
      end

      private

      def pipeline_builds(pipeline, status)
        # NOTE: Remove the else branch once the ci_jobs_finder_refactor FF is
        # removed. https://gitlab.com/gitlab-org/gitlab/-/issues/245183
        # rubocop: disable CodeReuse/ActiveRecord
        if Feature.enabled?(:ci_jobs_finder_refactor)
          params = { scope: status }
          ::Ci::JobsFinder
            .new(current_user: current_user, pipeline: pipeline, params: params)
            .execute
        elsif can?(current_user, :read_build, pipeline)
          builds = pipeline.builds
          builds = builds.where(status: status) if status.present?
          builds
        else
          ::Ci::Build.none
        end
      end
    end
  end
end
