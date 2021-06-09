# frozen_string_literal: true

module EE
  module Ci
    module Runner
      extend ActiveSupport::Concern

      def minutes_cost_factor(visibility_level)
        ::Gitlab::Ci::Minutes::CostFactor.new(runner_matcher).for_visibility(visibility_level)
      end

      def visibility_levels_without_minutes_quota
        ::Gitlab::VisibilityLevel.options.values.reject do |visibility_level|
          minutes_cost_factor(visibility_level) > 0
        end
      end

      class_methods do
        def has_shared_runners_with_non_zero_public_cost?
          ::Ci::Runner.instance_type.where('public_projects_minutes_cost_factor > 0').exists?
        end
      end
    end
  end
end
