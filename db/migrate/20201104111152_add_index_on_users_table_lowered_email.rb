# frozen_string_literal: true

class AddIndexOnUsersTableLoweredEmail < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  INDEX_NAME = 'index_users_on_lower_email'

  disable_ddl_transaction!

  def up
    add_concurrent_index :users, 'LOWER(email)', name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :users, INDEX_NAME
  end
end
