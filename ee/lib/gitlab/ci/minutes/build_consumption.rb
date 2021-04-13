# frozen_string_literal: true

module Gitlab
  module Ci
    module Minutes
      # Calculate the consumption of CI minutes based on a cost factor
      # assigned to the involved Runner.
      # The amount returned is a float so that internally we could track
      # an accurate usage of minutes/credits.
      class BuildConsumption
        def initialize(build, duration: nil)
          @build = build
          @duration = duration || @build.duration
        end

        def amount
          @amount ||= (@duration.to_f / 60 * cost_factor).round(2)
        end

        private

        def cost_factor
          # TODO: write specs
          return 0 unless @build.runner_id

          # If the consumption is calculated for a build executed by a specific
          # runner this should return 0 even if the runner has a default cost factor
          # of 1.0 for private projects
          return 0 unless @build.runner.instance_type?

          @build.runner.minutes_cost_factor(project_visibility_level)
        end

        def project_visibility_level
          @build.project.visibility_level
        end
      end
    end
  end
end
