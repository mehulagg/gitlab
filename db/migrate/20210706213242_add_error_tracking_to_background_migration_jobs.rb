# frozen_string_literal: true

class AddErrorTrackingToBackgroundMigrationJobs < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    unless column_exists?(:background_migration_jobs, :error_message)
      add_column :background_migration_jobs, :error_message, :text
    end

    add_text_limit :background_migration_jobs, :error_message, 1000
  end

  def down
    if column_exists?(:background_migration_jobs, :error_message)
      remove_column :background_migration_jobs, :error_message
    end
  end
end
