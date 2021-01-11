# frozen_string_literal: true

class CreateDastScans < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_table_with_constraints :dast_scans do |t| # rubocop:disable Migration/AddLimitToTextColumns
      t.references :project, null: false, foreign_key: false, index: false
      t.references :dast_site_profile, null: false, foreign_key: { on_delete: :cascade }
      t.references :dast_scanner_profile, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps_with_timezone

      # rubocop:disable Migration/AddLimitToTextColumns
      t.text :name, null: false
      t.text :description, null: false
      # rubocop:enable Migration/AddLimitToTextColumns

      t.index [:project_id, :name], unique: true

      t.text_limit :name, 255
      t.text_limit :description, 255
    end
  end

  def down
    with_lock_retries do
      drop_table :dast_scans
    end
  end
end
