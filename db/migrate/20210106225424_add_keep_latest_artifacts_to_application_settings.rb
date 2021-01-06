# frozen_string_literal: true

class AddKeepLatestArtifactsToApplicationSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :application_settings, :keep_latest_artifact, :boolean, default: true, null: false
    end
  end

  def down
    with_lock_retries do
      remove_column :application_settings, :keep_latest_artifact
    end
  end
end
