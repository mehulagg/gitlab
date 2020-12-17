# frozen_string_literal: true

class AddDevopsAdoptionSnapshotRangeEnd < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :analytics_devops_adoption_snapshots, :end_time, :timestamp
  end

  def down
    remove_column :analytics_devops_adoption_snapshots, :end_time
  end
end
