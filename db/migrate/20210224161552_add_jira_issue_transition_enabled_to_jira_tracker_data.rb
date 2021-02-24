# frozen_string_literal: true

class AddJiraIssueTransitionEnabledToJiraTrackerData < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    # We can't define a default value yet to ensure multi-version compatibility,
    # this will be added (along with a NON NULL constraint) in
    # db/post_migrate/20210303161701_finalize_add_jira_issue_transition_enabled_to_jira_tracker_data.rb
    add_column :jira_tracker_data, :jira_issue_transition_enabled, :boolean
  end
end
