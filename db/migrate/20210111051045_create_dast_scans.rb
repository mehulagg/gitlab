class CreateDastScans < ActiveRecord::Migration[6.0]
  def change
    create_table :dast_scans do |t|
      t.references :project, foreign_key: true
      t.references :dast_site_profile, foreign_key: true
      t.references :dast_scanner_profile, foreign_key: true
      t.text :name
      t.text :description

      t.timestamps
    end
  end
end
