# frozen_string_literal: true

class ChangeUniqueIndexOnSecurityFindings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  OLD_INDEX_NAME = 'index_security_findings_on_uuid'
  NEW_INDEX_NAME = 'index_security_findings_on_uuid_and_scan_id'

  disable_ddl_transaction!

  def up
    remove_concurrent_index_by_name :security_findings, OLD_INDEX_NAME

    add_concurrent_index :security_findings, [:uuid, :scan_id], unique: true, name: NEW_INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :security_findings, NEW_INDEX_NAME

    add_concurrent_index :security_findings, :uuid, unique: true, name: OLD_INDEX_NAME
  end
end
