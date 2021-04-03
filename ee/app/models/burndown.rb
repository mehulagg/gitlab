# frozen_string_literal: true

class Burndown
  include Gitlab::Utils::StrongMemoize

  attr_reader :issues, :start_date, :end_date, :due_date

  def initialize(issues, start_date, due_date)
    @start_date = start_date
    @due_date = due_date
    @end_date = if due_date.blank? || due_date > Date.today
                  Date.today
                else
                  due_date
                end

    @issues = filter_issues_created_before(@end_date, issues)
  end

  # Returns an array of milestone issue event data in the following format:
  # [{"created_at":"2019-03-10T16:00:00.039Z", "weight":null, "action":"closed" }, ... ]
  def as_json(opts = nil)
    return [] unless valid?

    burndown_events
  end

  def valid?
    start_date && due_date
  end

  private

  def burndown_events
    issues
      .map { |issue| burndown_events_for(issue) }
      .flatten
  end

  def burndown_events_for(issue)
    [
      transformed_create_event_for(issue),
      transformed_action_events_for(issue),
      transformed_legacy_closed_event_for(issue)
    ].compact
  end

  def milestone_events_per_issue
    return [] unless valid?

    strong_memoize(:milestone_events_per_issue) do
      Event
        .where(target: issues, action: [:closed, :reopened])
        .where('created_at <= ?', end_date.end_of_day)
        .order(:created_at)
        .group_by(&:target_id)
    end
  end

  # Use issue creation date as the source of truth for created events
  def transformed_create_event_for(issue)
    build_burndown_event(issue.created_at, issue.weight, :created)
  end

  # Use issue events as the source of truth for events other than 'created'
  def transformed_action_events_for(issue)
    events_for_issue = milestone_events_per_issue[issue.id]
    return [] unless events_for_issue

    previous_action = nil
    events_for_issue.map do |event|
      # It's possible that an event (we filter only closed or reopened actions)
      # is followed by another event with the same action - typically if both
      # commit and merge request closes an issue, then 'close' event may be
      # created for both of them. We can ignore these "duplicit" events because
      # if an event is already closed, another close action doesn't change its
      # state.
      next if event.action.to_s == previous_action.to_s

      previous_action = event.action
      build_burndown_event(event.created_at, issue.weight, event.action)
    end.compact
  end

  # If issue is closed but has no closed events, treat it as though closed on milestone start date
  def transformed_legacy_closed_event_for(issue)
    return [] unless issue.closed?
    return [] if milestone_events_per_issue[issue.id]&.any?(&:closed_action?)

    build_burndown_event(start_date.beginning_of_day, issue.weight, :closed)
  end

  def build_burndown_event(created_at, issue_weight, action)
    { created_at: created_at, weight: issue_weight, action: action.to_s }
  end

  def filter_issues_created_before(date, issues)
    return [] unless valid?

    issues.where('issues.created_at <= ?', date.end_of_day).includes(:project)
  end
end
