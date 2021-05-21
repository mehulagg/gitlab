# frozen_string_literal: true

module Iterations
  class RollOverIssuesService
    PermissionsError = Class.new(StandardError)

    BATCH_SIZE = 100

    def initialize(user, from_iteration, to_iteration)
      @user = user
      @from_iteration = from_iteration
      @to_iteration = to_iteration
    end

    def execute
      return ::ServiceResponse.error(message: _('Operation not allowed'), http_status: 403) unless can_roll_over_issues?

      from_iteration.issues.each_batch(of: BATCH_SIZE) do |issues|
        add_iteration_events, remove_iteration_events = iteration_events(issues, to_iteration.id)

        ActiveRecord::Base.transaction do
          issues.update_all(sprint_id: to_iteration.id)
          Gitlab::Database.bulk_insert(ResourceIterationEvent.table_name, add_iteration_events) # rubocop:disable Gitlab/BulkInsert
          Gitlab::Database.bulk_insert(ResourceIterationEvent.table_name, remove_iteration_events) # rubocop:disable Gitlab/BulkInsert
        end
      end

      ::ServiceResponse.success
    end

    private

    attr_reader :user, :from_iteration, :to_iteration

    def iteration_events(issues, new_iteration_id)
      add_iteration_events = []
      remove_iteration_events = []
      issues.map do |issue|
        add_iteration_events << common_event_attributes(issue).merge({ iteration_id: new_iteration_id, action: ResourceTimeboxEvent.actions[:add] })
        remove_iteration_events << common_event_attributes(issue).merge({ iteration_id: issue.sprint_id, action: ResourceTimeboxEvent.actions[:remove] })
      end

      [add_iteration_events, remove_iteration_events]
    end

    def common_event_attributes(issue)
      {
        created_at: Time.current,
        user_id: user.id,
        issue_id: issue.id
      }
    end

    def can_roll_over_issues?
      user && to_iteration && from_iteration &&
        to_iteration.group.root_ancestor.id == from_iteration.group.root_ancestor.id &&
        to_iteration.group.iteration_cadences_feature_flag_enabled? &&
        from_iteration.group.iteration_cadences_feature_flag_enabled? &&
        user.can?(:rollover_issues, to_iteration) &&
        !to_iteration.closed? && to_iteration.due_date > Date.current
    end
  end
end
