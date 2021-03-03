# frozen_string_literal: true

class AddLastWikiSyncedAtToProjectRegistry < ActiveRecord::Migration[4.2]
  DOWNTIME = false

  def change
    add_column :project_registry, :last_wiki_synced_at, :datetime # rubocop:disable Migration/Datetime
    add_column :project_registry, :last_wiki_successful_sync_at, :datetime # rubocop:disable Migration/Datetime
  end
end
