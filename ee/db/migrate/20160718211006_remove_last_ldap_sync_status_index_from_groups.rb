# Migration type: online without errors (works on previous version and new one)

# rubocop:disable RemoveIndex
class RemoveLastLdapSyncStatusIndexFromGroups < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers
  disable_ddl_transaction!

  DOWNTIME = false

  def up
    remove_index :namespaces, column: :last_ldap_sync_at if index_exists?(:namespaces, :last_ldap_sync_at)
  end

  def down
    add_concurrent_index :namespaces, :last_ldap_sync_at
  end
end
