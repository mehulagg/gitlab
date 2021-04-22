# frozen_string_literal: true

module Users
  # Service class for calculating and persisting the number of assigned open issues for a user.
  class UpdateAssignedOpenIssueCountService
    attr_accessor :target_user

    def initialize(target_user:)
      @target_user = target_user

      raise ArgumentError.new("Please provide a target user") unless target_user.is_a?(User)
    end

    def execute
      Rails.cache.delete(user_assigned_issue_cache)
      value = calculate_count
      Rails.cache.write(user_assigned_issue_cache, value, expires_in: target_user.count_cache_validity_period)

      ServiceResponse.success(payload: { count: value })
    rescue => e
      ServiceResponse.error(message: e.message)
    end

    private

    def user_assigned_issue_cache
      ['users', target_user.id, 'assigned_open_issues_count']
    end

    def calculate_count
      IssuesFinder.new(target_user, assignee_id: target_user.id, state: 'opened', non_archived: true).execute.count
    end
  end
end
