# frozen_string_literal: true

module Gitlab
  module Ci
    module Minutes
      class CostFactor
        def initialize(runner)
          @runner = runner
        end

        def enabled?(visibility_level)
          for_visibility(visibility_level) > 0
        end

        def disabled?(visibility_level)
          !enabled?(visibility_level)
        end

        def for_visibility(visibility_level)
          return 0.0 unless @runner.instance_type?

          case visibility_level
          when ::Gitlab::VisibilityLevel::PUBLIC
            @runner.public_projects_minutes_cost_factor
          when ::Gitlab::VisibilityLevel::PRIVATE, ::Gitlab::VisibilityLevel::INTERNAL
            @runner.private_projects_minutes_cost_factor
          else
            raise ArgumentError, 'Invalid visibility level'
          end
        end
      end
    end
  end
end
