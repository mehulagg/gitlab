# frozen_string_literal: true

class FinalizeAddJiraIssueTransitionEnabledToJiraTrackerData < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  class JiraTrackerData < ActiveRecord::Base
    self.table_name = 'jira_tracker_data'
  end

  def up
    JiraTrackerData.reset_column_information
    JiraTrackerData
      .where(jira_issue_transition_enabled: nil)
      .update_all("jira_issue_transition_enabled = (jira_issue_transition_id IS NOT NULL AND jira_issue_transition_id != '')")

    change_column_default :jira_tracker_data, :jira_issue_transition_enabled, false
    change_column_null :jira_tracker_data, :jira_issue_transition_enabled, false
  end

  def down
    change_column_null :jira_tracker_data, :jira_issue_transition_enabled, true
    change_column_default :jira_tracker_data, :jira_issue_transition_enabled, nil
  end
end
