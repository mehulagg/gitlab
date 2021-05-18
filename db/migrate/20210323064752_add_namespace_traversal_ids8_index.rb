# frozen_string_literal: true

class AddNamespaceTraversalIds8Index < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_namespaces_on_traversal_ids8'

  disable_ddl_transaction!

  def up
    add_concurrent_index :namespaces, :traversal_ids8, using: :gin, name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :namespaces, INDEX_NAME
  end
end
