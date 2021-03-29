# frozen_string_literal: true

class ScheduleBackfillTraversalIdsCom < ActiveRecord::Migration[6.0]

  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 500
  DELAY_INTERVAL = 2.minutes.to_i

  disable_ddl_transaction!

  class Namespace < ActiveRecord::Base
    include ::EachBatch

    self.table_name = 'namespaces'
  end

  def up
    return unless Gitlab.com?

    top_level_index = 0

    # Personal namespaces and top-level groups
    Namespace.where(parent_id: nil).each_batch(of: BATCH_SIZE) do |batch, index|
      delay = index * DELAY_INTERVAL
      range = batch.pluck('MIN(id)', 'MAX(id)').first
      BackgroundMigrationWorker.perform_in(delay, 'BackfillTopLevelTraversalIds', range)
      top_level_index = index
    end

    # Subgroups
    Namespace.where('parent_id IS NOT NULL').each_batch(of: BATCH_SIZE) do |batch, index|
      delay = (top_level_index + index) * DELAY_INTERVAL
      range = batch.pluck('MIN(id)', 'MAX(id)').first
      BackgroundMigrationWorker.perform_in(delay, 'BackfillTraversalIds', range)
    end
  end
end
