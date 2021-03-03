# frozen_string_literal: true

class CreateProjectRegistry < ActiveRecord::Migration[4.2]
  def change
    create_table :project_registry do |t|
      t.integer  :project_id, null: false
      t.datetime :last_repository_synced_at # rubocop:disable Migration/Datetime
      t.datetime :last_repository_successful_sync_at # rubocop:disable Migration/Datetime

      t.datetime :created_at, null: false # rubocop:disable Migration/Datetime
    end
  end
end
