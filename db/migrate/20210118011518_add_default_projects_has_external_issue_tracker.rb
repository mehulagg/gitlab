# frozen_string_literal: true

class AddDefaultProjectsHasExternalIssueTracker < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    change_column_default(:projects, :has_external_issue_tracker, from: nil, to: false)
  end
end
