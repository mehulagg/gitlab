# frozen_string_literal: true

class AddProvisionedByGroupToUserDetails < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_user_details_on_provisioned_by_group'

  disable_ddl_transaction!

  def up
    with_lock_retries do
      add_column(:user_details, :provisioned_by_group, :integer) unless column_exists?(:user_details, :provisioned_by_group)
    end

    add_concurrent_foreign_key :user_details, :namespaces, column: :provisioned_by_group, on_delete: :cascade
    add_concurrent_index :user_details, :provisioned_by_group, name: INDEX_NAME
  end

  def down
    remove_foreign_key_without_error :user_details, column: :provisioned_by_group
    remove_concurrent_index_by_name :user_details, INDEX_NAME

    with_lock_retries do
      remove_column(:user_details, :provisioned_by_group) if column_exists?(:user_details, :provisioned_by_group)
    end
  end
end
