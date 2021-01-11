class CreateDastScans < ActiveRecord::Migration[6.0]
  def up
    create_table :dast_scans do |t|
      t.bigint :project_id, null: false
      t.bigint :dast_site_profile_id, null: false
      t.bigint :dast_scanner_profile_id, null: false

      t.timestamps_with_timezone

      t.text :name
      t.text :description
    end

    add_index :dast_scans, :project_id
    add_index :dast_scans, :dast_site_profile_id
    add_index :dast_scans, :dast_scanner_profile_id
  end

  def down
    drop_table :dast_scans
  end
end
