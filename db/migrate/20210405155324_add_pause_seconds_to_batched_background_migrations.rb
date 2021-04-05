# frozen_string_literal: true

class AddPauseSecondsToBatchedBackgroundMigrations < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :batched_background_migrations, :pause_seconds, :float, null: false, default: 0.1
  end
end
