# frozen_string_literal: true

module Gitlab
  module Ci
    module Minutes
      class CostFactor
        NEW_NAMESPACE_PUBLIC_PROJECT_COST_FACTOR = 0.01
        RELEASE_DAY = Date.new(2021, 7, 17).freeze

        def initialize(runner_matcher)
          ensure_runner_matcher_instance(runner_matcher)

          @runner_matcher = runner_matcher
        end

        def enabled?(visibility_level)
          for_visibility(visibility_level) > 0
        end

        def disabled?(visibility_level)
          !enabled?(visibility_level)
        end

        def for_project(project)
          cost_factor = for_visibility(project.visibility_level)

          if @runner_matcher.instance_type? && cost_factor == 0 && project.root_namespace.created_at >= RELEASE_DAY
            NEW_NAMESPACE_PUBLIC_PROJECT_COST_FACTOR
          else
            cost_factor
          end
        end

        def for_visibility(visibility_level)
          return 0.0 unless @runner_matcher.instance_type?

          case visibility_level
          when ::Gitlab::VisibilityLevel::PUBLIC
            @runner_matcher.public_projects_minutes_cost_factor
          when ::Gitlab::VisibilityLevel::PRIVATE, ::Gitlab::VisibilityLevel::INTERNAL
            @runner_matcher.private_projects_minutes_cost_factor
          else
            raise ArgumentError, 'Invalid visibility level'
          end
        end

        private

        def ensure_runner_matcher_instance(runner_matcher)
          unless runner_matcher.is_a?(Matching::RunnerMatcher)
            raise ArgumentError, 'only Matching::RunnerMatcher objects allowed'
          end
        end
      end
    end
  end
end
