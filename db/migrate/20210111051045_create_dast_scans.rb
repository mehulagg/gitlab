# frozen_string_literal: true

class CreateDastScans < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :dast_scans do |t|
        t.bigint :project_id, null: false
        t.bigint :dast_site_profile_id, null: false
        t.bigint :dast_scanner_profile_id, null: false

        t.timestamps_with_timezone

        t.text :name, null: false
        t.text :description, null: false
      end
    end

    add_concurrent_index :dast_scans, :project_id
    add_concurrent_index :dast_scans, :dast_site_profile_id
    add_concurrent_index :dast_scans, :dast_scanner_profile_id
    add_concurrent_index :dast_scans, [:project_id, :name], unique: true

    add_text_limit :dast_scans, :name, 255
    add_text_limit :dast_scans, :description, 255
  end

  def down
    with_lock_retries do
      drop_table :dast_scans
    end
  end
end
