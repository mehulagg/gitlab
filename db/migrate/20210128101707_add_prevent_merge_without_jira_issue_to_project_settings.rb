# frozen_string_literal: true

class AddPreventMergeWithoutJiraIssueToProjectSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :project_settings, :prevent_merge_without_jira_issue, :boolean, null: false, default: false
  end
end
