# frozen_string_literal: true

class AddPartitionedWebHookLogFk < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  # rubocop:disable Migration/AddReference
  # Reason: we can't use add_concurrent_foreign_key on partitioned tables
  #   It sets the constraint to `NOT VALID` before validating it
  #   Setting an FK to NOT VALID is not supported right now (up to PG13)
  # Solution: Use a normal add_foreign_key inside a with_lock_retries
  #           in a post deployment migration (as it may take some time to validate)
  def up
    unless foreign_key_exists?(:forked_project_links, :projects, column: :forked_to_project_id)
      with_lock_retries do
        add_foreign_key :web_hook_logs_part_0c5294f417,
          :web_hooks,
          column: :web_hook_id,
          on_delete: :cascade
      end
    end
  end
  # rubocop:enable Migration/AddReference

  def down
    with_lock_retries do
      remove_foreign_key_if_exists :web_hook_logs_part_0c5294f417, column: :web_hook_id
    end
  end
end
