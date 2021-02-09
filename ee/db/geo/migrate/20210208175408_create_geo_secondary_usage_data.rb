# frozen_string_literal: true

class CreateGeoSecondaryUsageData < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  def change
    create_table :secondary_usage_data do |t|
      t.timestamps_with_timezone
      t.jsonb :data, null: false, default: {}
    end
  end
end
