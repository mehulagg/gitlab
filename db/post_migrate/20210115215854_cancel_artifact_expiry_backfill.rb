# frozen_string_literal: true

class CancelArtifactExpiryBackfill < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  MIGRATION = 'BackfillArtifactExpiryDate'

  disable_ddl_transaction!

  def change
    Gitlab::BackgroundMigration.steal(MIGRATION)
  end
end
