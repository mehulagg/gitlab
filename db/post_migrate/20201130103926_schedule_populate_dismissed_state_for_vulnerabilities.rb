# frozen_string_literal: true

class SchedulePopulateDismissedStateForVulnerabilities < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 1_000
  DELAY_INTERVAL = 2.minutes.to_i
  MIGRATION_CLASS = 'PopulateDismissedStateForVulnerabilities'

  disable_ddl_transaction!

  def up
    vulnerabilities = exec_query <<~SQL
      SELECT DISTINCT "vulnerability_occurrences"."vulnerability_id"
      FROM "vulnerability_occurrences"
      JOIN "vulnerability_feedback"
      ON "vulnerability_occurrences"."project_id" = "vulnerability_feedback"."project_id"
        AND "vulnerability_occurrences"."report_type" = "vulnerability_feedback"."category"
        AND ENCODE("vulnerability_occurrences"."project_fingerprint", 'hex') = "vulnerability_feedback"."project_fingerprint"
        AND "vulnerability_feedback"."feedback_type" = 0
      ORDER BY "vulnerability_occurrences"."vulnerability_id" ASC
    SQL

    return if vulnerabilities.rows.blank?

    vulnerabilities.rows.flatten.in_groups_of(BATCH_SIZE, false).each_with_index do |vulnerability_ids, index|
      migrate_in(index * DELAY_INTERVAL, MIGRATION_CLASS, [vulnerability_ids])
    end
  end

  def down
    # no-op
  end
end
