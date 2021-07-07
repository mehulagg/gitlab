# frozen_string_literal: true

class CleanupJiraTrackerDataDeploymentType < ActiveRecord::Migration[6.1]
  MIGRATION = 'UpdateJiraTrackerDataDeploymentTypeBasedOnUrl'

  disable_ddl_transaction!

  def up
    Gitlab::BackgroundMigration.steal(MIGRATION)

    model = Gitlab::BackgroundMigration::UpdateJiraTrackerDataDeploymentTypeBasedOnUrl::JiraTrackerData.include(EachBatch)

    model.deployment_unknown.each_batch do |batch|
      range = batch.pluck('MIN(id)', 'MAX(id)').first

      Gitlab::BackgroundMigration::UpdateJiraTrackerDataDeploymentTypeBasedOnUrl.new.perform(*range)
    end
  end

  def down
    # no-op
  end
end
