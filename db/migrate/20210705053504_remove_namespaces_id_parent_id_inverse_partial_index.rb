# frozen_string_literal: true

class RemoveNamespacesIdParentIdInversePartialIndex < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  NAME = 'index_namespaces_id_parent_id_is_not_null'

  disable_ddl_transaction!

  def up
    remove_concurrent_index :namespaces, :id, name: NAME
  end

  def down
    add_concurrent_index :namespaces, :id, where: 'parent_id IS NOT NULL', name: NAME
  end
end
