# frozen_string_literal: true

class AddAllowToEditCommitToProjectSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    with_lock_retries do
      add_column :project_settings, :allow_edit_commit_messages, :boolean, default: false, null: false
    end
  end

  def down
    with_lock_retries do
      remove_column :project_settings, :allow_edit_commit_messages
    end
  end
end
