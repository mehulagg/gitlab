# frozen_string_literal: true

# MergeRequests::ByApprovers class
#
# Used to filter MergeRequests collections by approvers

module MergeRequests
  class ByApproversFinder
    attr_reader :usernames, :ids

    def initialize(usernames, ids)
      @usernames = usernames.to_a.map(&:to_s)
      @ids = ids
    end

    def execute(items)
      if by_no_approvers?
        without_approvers(items)
      elsif by_any_approvers?
        with_any_approvers(items)
      elsif ids.present?
        find_approvers_by_ids(items)
      elsif usernames.present?
        find_approvers_by_names(items)
      else
        items
      end
    end

    private

    def by_no_approvers?
      includes_custom_label?(IssuableFinder::Params::FILTER_NONE)
    end

    def by_any_approvers?
      includes_custom_label?(IssuableFinder::Params::FILTER_ANY)
    end

    def includes_custom_label?(label)
      ids.to_s.downcase == label || usernames.map(&:downcase).include?(label)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def without_approvers(items)
      items
        .left_outer_joins(:approval_rules)
        .joins('LEFT OUTER JOIN approval_project_rules ON approval_project_rules.project_id = merge_requests.target_project_id')
        .where(approval_merge_request_rules: { id: nil })
        .where(approval_project_rules: { id: nil })
    end

    def with_any_approvers(items)
      items.select_from_union([
        items.joins(:approval_rules),
        items.joins('INNER JOIN approval_project_rules ON approval_project_rules.project_id = merge_requests.target_project_id')
      ])
    end

    def find_approvers_by_names(items)
      with_users_filtered_by_criteria(items, :username, usernames)
    end

    def find_approvers_by_ids(items)
      with_users_filtered_by_criteria(items, :id, ids)
    end

    def with_users_filtered_by_criteria(items, field, values)
      items.select_from_union(
        [
          users_mrs(items, field, values, :users),
          users_mrs(items, field, values, { groups: :users }),
          project_users_mrs(items, field, values, :users),
          project_users_mrs(items, field, values, { groups: :users })
        ]
      )
    end

    def users_mrs(items, field, values, joins)
      filter_by_existence(items, values) do |value|
        ApprovalMergeRequestRule
          .joins(joins)
          .where(
            ApprovalMergeRequestRule.arel_table[:merge_request_id].eq(MergeRequest.arel_table[:id])
              .and(User.arel_table[field].eq(value))
          )
      end
    end

    def mrs_without_overridden_rules(items)
      items.left_outer_joins(:approval_rules).where(approval_merge_request_rules: { id: nil })
    end

    def project_users_mrs(items, field, values, joins)
      items = mrs_without_overridden_rules(items)
      filter_by_existence(items, values) do |value|
        Project
          .joins(approval_rules: joins)
          .where(
            Project.arel_table[:id].eq(MergeRequest.arel_table[:target_project_id])
              .and(User.arel_table[field].eq(value))
          )
      end
    end

    def filter_by_existence(items, values)
      values.reduce(items) do |items, value|
        items.where('EXISTS (?)', yield(value))
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
