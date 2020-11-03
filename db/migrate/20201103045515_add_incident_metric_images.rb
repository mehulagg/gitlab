# frozen_string_literal: true

class AddIncidentMetricImages < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :metric_image_uploads do |t|
      t.references :issue, null: false, index: true, foreign_key: { on_delete: :cascade }
      t.string :file, limit: 255
      t.integer :file_store, limit: 2
    end
  end
end
