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
        @scalar_params ||= super + [:weight, :epic_id, :include_subepics, :iteration_id, :iteration_title]
      end

      override :negatable_params
      def negatable_params
        @negatable_params ||= super + [:iteration_title]
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
      return items unless params.by_iteration?

      if params.filter_by_no_iteration?
        items.no_iteration
      elsif params.filter_by_any_iteration?
        items.any_iteration
      elsif params.filter_by_iteration_title?
        items.with_iteration_title(params[:iteration_title])
      else
        items.in_iterations(params[:iteration_id])
      end
    end

    override :filter_negated_items
    def filter_negated_items(items)
      items = by_negated_epic(items)
      items = by_negated_iteration(items)

      super(items)
    end

    def by_negated_epic(items)
      return items unless not_params[:epic_id].present?

      items.not_in_epics(not_params[:epic_id].to_i)
    end

    def by_negated_iteration(items)
      return items unless not_params[:iteration_title].present?

      items.without_iteration_title(not_params[:iteration_title])
    end
  end
end
