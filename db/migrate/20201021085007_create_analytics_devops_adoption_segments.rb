# frozen_string_literal: true

class CreateAnalyticsDevopsAdoptionSegments < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  # rubocop:disable Migration/AddLimitToTextColumns
  def up
    create_table :analytics_devops_adoption_segments, if_not_exists: true do |t|
      t.text :name, null: false
      t.datetime_with_timezone :last_recorded_at

      t.index :name, unique: true
      t.timestamps_with_timezone
    end

    add_text_limit :dast_site_profiles, :name, 255
  end
  # rubocop:enable Migration/AddLimitToTextColumns

  def down
    drop_table :analytics_devops_adoption_segments
  end
end
