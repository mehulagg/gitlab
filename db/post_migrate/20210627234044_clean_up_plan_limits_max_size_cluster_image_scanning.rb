# frozen_string_literal: true

class CleanUpPlanLimitsMaxSizeClusterImageScanning < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers::V2

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    cleanup_concurrent_column_rename :plan_limits,
      :ci_max_artifact_size_running_container_scanning,
      :ci_max_artifact_size_cluster_image_scanning
  end

  def down
    undo_cleanup_concurrent_column_rename :plan_limits,
      :ci_max_artifact_size_running_container_scanning,
      :ci_max_artifact_size_cluster_image_scanning
  end
end
