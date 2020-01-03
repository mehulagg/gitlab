# frozen_string_literal: true

class CreatePackagesComposerMetadata < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    create_table :packages_composer_metadata, id: :bigserial do |t|
      t.timestamps_with_timezone null: false

      t.references :package,
                   type: :bigint,
                   null: false,
                   index: { unique: true },
                   foreign_key: { to_table: :packages_packages, on_delete: :cascade }

      t.string "name", limit: 255, null: false
      t.string "version", limit: 255, null: false
      t.jsonb "json", null: false
    end
  end
end
