# frozen_string_literal: true

class AddProjectToTimelogs < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      add_column :timelogs, :project_id, :integer
    end

    add_concurrent_foreign_key :timelogs, :projects, column: :project_id, on_delete: :cascade
  end

  def down
    with_lock_retries do
      remove_foreign_key :timelogs, column: :project_id
    end

    remove_column :timelogs, :project_id
  end
end
