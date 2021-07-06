# frozen_string_literal: true

module Gitlab
  module Ci
    module Minutes
      # Calculate the consumption of CI minutes based on a cost factor
      # assigned to the involved Runner.
      # The amount returned is a float so that internally we could track
      # an accurate usage of minutes/credits.
      class BuildConsumption
        def initialize(build, duration)
          @build = build
          @duration = duration
        end

        def amount
          @amount ||= (@duration.to_f / 60 * cost_factor).round(2)
        end

        private

        def cost_factor
          @build&.runner&.minutes_cost_factor(project_visibility_level) || 0
        end

        def project_visibility_level
          @build.project.visibility_level
        end
      end
    end
  end
end
