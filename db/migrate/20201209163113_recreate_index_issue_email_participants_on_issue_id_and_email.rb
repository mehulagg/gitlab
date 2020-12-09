# frozen_string_literal: true

class RecreateIndexIssueEmailParticipantsOnIssueIdAndEmail < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    remove_concurrent_index_by_name :issue_email_participants, 'index_issue_email_participants_on_issue_id_and_email'
    add_concurrent_index :issue_email_participants, 'issue_id, lower(email)', unique: true, name: 'index_issue_email_participants_on_issue_id_and_lower_email'
  end

  def down
    remove_concurrent_index_by_name :issue_email_participants, 'index_issue_email_participants_on_issue_id_and_lower_email'
    add_concurrent_index :issue_email_participants, [:issue_id, :email], unique: true, name: 'index_issue_email_participants_on_issue_id_and_email'
  end
end
