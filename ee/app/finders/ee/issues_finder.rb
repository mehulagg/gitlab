# frozen_string_literal: true

module EE
  module IssuesFinder
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Utils::StrongMemoize

    class_methods do
      extend ::Gitlab::Utils::Override

      override :scalar_params
      def scalar_params
        @scalar_params ||= super + [:weight, :epic_id, :include_subepics]
      end
    end

    override :filter_items
    def filter_items(items)
      issues = by_weight(super)
      issues = by_epic(issues)
      by_iteration(issues)
    end

    private

    # rubocop: disable CodeReuse/ActiveRecord
    def by_weight(items)
      return items unless params.weights?

      if params.filter_by_no_weight?
        items.where(weight: [-1, nil])
      elsif params.filter_by_any_weight?
        items.where.not(weight: [-1, nil])
      else
        items.where(weight: params[:weight])
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    override :by_assignee
    def by_assignee(items)
      if params.assignees.any?
        params.assignees.each do |assignee|
          items = items.assigned_to(assignee)
        end

        return items
      end

      super
    end

    def by_epic(items)
      return items unless params.by_epic?

      if params.filter_by_no_epic?
        items.no_epic
      elsif params.filter_by_any_epic?
        items.any_epic
      else
        items.in_epics(params.epics)
      end
    end

    def by_iteration(items)
      return items unless params.iterations

      case params.iterations.to_s.downcase
      when ::IssuableFinder::Params::FILTER_NONE
        items.no_iteration
      when ::IssuableFinder::Params::FILTER_ANY
        items.any_iteration
      else
        items.in_iterations(params.iterations)
      end
    end
  end
end
