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
          @build.runner.cost_factor_for_project(@build.project)
        end
      end
    end
  end
end
