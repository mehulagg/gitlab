# frozen_string_literal: true

module EE
  module Ci
    module Runner
      extend ActiveSupport::Concern

      class_methods do
        def has_shared_runners_with_non_zero_public_cost?
          ::Ci::Runner.instance_type.where('public_projects_minutes_cost_factor > 0').exists?
        end
      end

      def cost_factor_for_project(visibility_level)
        cost_factor.for_project(visibility_level)
      end

      def visibility_levels_without_minutes_quota
        ::Gitlab::VisibilityLevel.options.values.reject do |visibility_level|
          cost_factor.for_visibility(visibility_level) > 0
        end
      end

      private

      def cost_factor
        ::Gitlab::Ci::Minutes::CostFactor.new(runner_matcher)
      end
    end
  end
end
