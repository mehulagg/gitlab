# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Matching
        module RunnerMatcher
          def matches_quota?(build_matcher)
            cost_factor = minutes_cost_factor(build_matcher.project.visibility_level)

            cost_factor == 0 || (cost_factor > 0 && !minutes_used_up?(build_matcher))
          end

          private

          def minutes_cost_factor(visibility_level)
            return 0.0 unless instance_type?

            case visibility_level
            when ::Gitlab::VisibilityLevel::PUBLIC
              public_projects_minutes_cost_factor
            when ::Gitlab::VisibilityLevel::PRIVATE, ::Gitlab::VisibilityLevel::INTERNAL
              private_projects_minutes_cost_factor
            else
              raise ArgumentError, 'Invalid visibility level'
            end
          end

          def minutes_used_up?(build_matcher)
            build_matcher
              .project
              .ci_minutes_quota
              .minutes_used_up?
          end
        end
      end
    end
  end
end
