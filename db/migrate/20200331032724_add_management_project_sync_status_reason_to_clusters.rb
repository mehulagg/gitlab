# frozen_string_literal: true

class AddManagementProjectSyncStatusReasonToClusters < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :clusters, :management_project_sync_status_reason, :text
  end
end
