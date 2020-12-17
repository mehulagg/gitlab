# frozen_string_literal: true

class AddDevopsAdoptionSnapshotNotNull < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    execute "UPDATE analytics_devops_adoption_snapshots SET end_time = date_trunc('month', recorded_at) - interval '1 millisecond'"

    add_not_null_constraint :analytics_devops_adoption_snapshots, :end_time
  end

  def down
    remove_not_null_constraint :analytics_devops_adoption_snapshots, :end_time
  end
end
