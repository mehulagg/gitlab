# frozen_string_literal: true

class ChangeTraversalIdsToBigint < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    change_column_type_concurrently :namespaces, :traversal_ids, 'bigint[]'
  end

  def down
    undo_change_column_type_concurrently :namespaces, :traversal_ids
  end
end
