# frozen_string_literal: true

class CreateGeoSecondaryUsageData < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :secondary_usage_data do |t|
      t.timestamps_with_timezone
      t.jsonb :payload, null: false, default: {}
    end
  end
end
