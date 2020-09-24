# frozen_string_literal: true

module EE
  module Boards
    module Lists
      module UpdateService
        extend ::Gitlab::Utils::Override

        include MaxLimits

        private

        override :execute_by_params
        def execute_by_params(list)
          updated_max_limits = update_max_limits(list)

          super || updated_max_limits
        end

        def update_max_limits(list)
          return unless list.wip_limits_available? && can_admin?(list)

          attrs = max_limit_settings_by_params
          list.update(attrs) unless attrs.empty?
        end

        def max_limit_settings_by_params
          {}.tap do |attrs|
            attrs.merge!(list_max_limit_attributes_by_params) if max_limits_provided?
            attrs.merge!(limit_metric_by_params) if limit_metric_provided?
          end
        end

        def limit_metric_by_params
          { limit_metric: params[:limit_metric] }
        end

        def limit_metric_provided?
          params.key?(:limit_metric)
        end
      end
    end
  end
end
