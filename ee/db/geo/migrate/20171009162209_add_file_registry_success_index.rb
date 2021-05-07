# frozen_string_literal: true

class AddFileRegistrySuccessIndex < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :file_registry, :success
  end

  def down
    remove_concurrent_index :file_registry, :success
  end
end
