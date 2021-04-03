# frozen_string_literal: true

class AddLastSyncFailureToProjectRegistry < ActiveRecord::Migration[4.2]
  DOWNTIME = false

  # rubocop:disable Migration/PreventStrings
  def change
    add_column :project_registry, :last_repository_sync_failure, :string
    add_column :project_registry, :last_wiki_sync_failure, :string
  end
  # rubocop:enable Migration/PreventStrings
end
