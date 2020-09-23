# frozen_string_literal: true

module EE
  module Boards
    module Lists
      module MaxLimits
        def list_max_limit_attributes_by_params
          {}.tap do |list_attrs|
            list_attrs[:max_issue_count] = max_issue_count_by_params if max_issue_count?
            list_attrs[:max_issue_weight] = max_issue_weight_by_params if max_issue_weight?
          end
        end

        def max_issue_count?
          params[:max_issue_count].present?
        end

        def max_issue_weight?
          params[:max_issue_weight].present?
        end

        def max_limits_provided?
          max_issue_count? || max_issue_weight?
        end

        def max_issue_count_by_params
          params.fetch(:max_issue_count, 0).to_i
        end

        def max_issue_weight_by_params
          params.fetch(:max_issue_weight, 0).to_i
        end
      end
    end
  end
end
