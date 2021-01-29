# frozen_string_literal: true

class AddNamespaceTraversalIdsIndex < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :namespaces, :traversal_ids, using: :gin
  end

  def down
    remove_concurrent_index :namespaces, :traversal_ids, using: :gin
  end
end
