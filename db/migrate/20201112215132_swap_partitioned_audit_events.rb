# frozen_string_literal: true

class SwapPartitionedAuditEvents < ActiveRecord::Migration[6.0]
  include Gitlab::Database::PartitioningMigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    replace_with_partitioned_table :audit_events
  end

  def down
    rollback_replace_with_partitioned_table :audit_events
  end
end
