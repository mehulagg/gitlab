# frozen_string_literal: true

class AddDastScannerProfileFkForDastScan < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :dast_scans, :dast_scanner_profiles, column: :dast_scanner_profile_id, on_delete: :cascade
  end

  def down
    with_lock_retries do
      remove_foreign_key :dast_scans, column: :dast_scanner_profile_id
    end
  end
end
