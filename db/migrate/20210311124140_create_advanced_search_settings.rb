# frozen_string_literal: true

class CreateAdvancedSearchSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      create_table :advanced_search_settings do |t|
        t.jsonb :number_of_replicas, null: false
        t.jsonb :number_of_shards, null: false

        t.timestamps_with_timezone null: false
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :advanced_search_settings
    end
  end
end
