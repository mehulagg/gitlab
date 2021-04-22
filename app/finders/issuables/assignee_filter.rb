# frozen_string_literal: true

module Issuables
  class AssigneeFilter < BaseFilter
    def filter
      filtered = by_assignee(issuables)
      by_negated_assignee(filtered)
    end

    private

    def by_assignee(issuables)
      if filter_by_no_assignee?
        issuables.unassigned
      elsif filter_by_any_assignee?
        issuables.assigned
      elsif has_assignee_param?(params)
        filter_by_assignees(issuables)
      else
        issuables
      end
    end

    def by_negated_assignee(issuables)
      return issuables unless has_assignee_param?(not_params)

      issuables.not_assigned_to(assignee_ids(not_params))
    end

    def filter_by_no_assignee?
      params[:assignee_id].to_s.downcase == FILTER_NONE
    end

    def filter_by_any_assignee?
      params[:assignee_id].to_s.downcase == FILTER_ANY
    end

    def has_assignee_param?(specific_params)
      return if specific_params.nil?

      specific_params[:assignee_id].present? || specific_params[:assignee_username].present?
    end

    def filter_by_assignees(issuables)
      assignee_ids = assignee_ids(params)

      return issuables.none if assignee_ids.blank?

      assignee_ids.each do |assignee_id|
        issuables = issuables.assigned_to(assignee_id)
      end

      issuables
    end

    def assignee_ids(specific_params)
      if specific_params[:assignee_id].present?
        specific_params[:assignee_id]
      elsif specific_params[:assignee_username].present?
        User.by_username(specific_params[:assignee_username]).select(:id)
      end
    end
  end
end
