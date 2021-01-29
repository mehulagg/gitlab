# frozen_string_literal: true

module Gitlab
  module Ci
    module Minutes
      class BuildConsumption
        def initialize(build)
          @build = build
        end

        def amount
          (@build.duration * cost_factor).to_i
        end

        private

        def cost_factor
          @build.runner.minutes_cost_factor(project_visibility_level)
        end

        def project_visibility_level
          @build.project.visibility_level
        end
      end
    end
  end
end
