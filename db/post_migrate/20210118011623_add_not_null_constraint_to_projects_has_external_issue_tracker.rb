# frozen_string_literal: true

class AddNotNullConstraintToProjectsHasExternalIssueTracker < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_not_null_constraint :projects, :has_external_issue_tracker, validate: false
  end

  def down
    remove_not_null_constraint :projects, :has_external_issue_tracker
  end
end
