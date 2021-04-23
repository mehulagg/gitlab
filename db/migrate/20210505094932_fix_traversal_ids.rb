# frozen_string_literal: true

class FixTraversalIds < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    change_column :namespaces, :traversal_ids, 'bigint[]'
  end
  
  def down
    change_column :namespaces, :traversal_ids, 'integer[]'
  end
end
