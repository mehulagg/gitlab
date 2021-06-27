# frozen_string_literal: true

class RenamePlanLimitsMaxSizeRunningContainerScanningToClusterImageScanning < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    rename_column_concurrently :plan_limits, :ci_max_artifact_size_running_container_scanning, :ci_max_artifact_size_cluster_image_scanning
  end

  def down
    undo_rename_column_concurrently :plan_limits, :ci_max_artifact_size_running_container_scanning, :ci_max_artifact_size_cluster_image_scanning
  end
end
