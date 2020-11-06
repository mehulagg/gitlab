# frozen_string_literal: true

class AddIncidentMetricImages < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :metric_images do |t|
      t.references :issue, null: false, index: true, foreign_key: { on_delete: :cascade }
      t.text :url
      t.text :file, null: false
      t.integer :file_store, limit: 2
    end

    add_text_limit(:metric_images, :url, 255)
    add_text_limit(:metric_images, :file, 255)
  end

  def down
    drop_table :metric_images
  end
end
