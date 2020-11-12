# frozen_string_literal: true

class ScheduleRecalculateUuidOnVulnerabilitiesOccurrences < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  MIGRATION = 'RecalculateVulnerabilitiesOccurrencesUuid'
  BATCH_SIZE = 2_500
  DELAY_INTERVAL = 2.minutes.to_i

  disable_ddl_transaction!

  class VulnerabilitiesFinding < ActiveRecord::Base
    include ::EachBatch

    self.table_name = "vulnerability_occurrences"
  end

  def up
    say "Scheduling #{MIGRATION} jobs"

    VulnerabilitiesFinding.each_batch(of: BATCH_SIZE) do |findings, index|
      delay = index * DELAY_INTERVAL
      finding_ids = findings.map(&:id)
      migrate_in(delay, MIGRATION, [finding_ids])
    end
  end

  def down
    # no-op
  end
end
