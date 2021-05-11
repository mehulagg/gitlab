# frozen_string_literal: true

class BackfillEscalationPoliciesForOncallSchedules < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  # Creates a single new escalation policy for projects which have
  # existing on-call schedules. Only one schedule is expected
  # per project, but it is possible to have multiple.
  #
  # An escalation rule is created for each existing schedule.
  # For projects with multiple schedules, the name of the first saved
  # schedule will be used for the policy's description.
  #
  # Skips projects which already have escalation policies & schedules.
  def up
    result = ApplicationRecord.connection.exec_insert(<<~SQL.squish)
      INSERT INTO incident_management_escalation_policies(
        project_id,
        name,
        description
      )
        SELECT
          DISTINCT ON (project_id) project_id,
          'On-call Escalation Policy',
          CONCAT('Immediately notify ', name)
        FROM incident_management_oncall_schedules
        WHERE project_id NOT IN (
          SELECT DISTINCT project_id
          FROM incident_management_escalation_policies
        )
        ORDER BY project_id, id
    SQL

    policy_ids = result.rows.map(&:first)
    return unless policy_ids.any?

    ApplicationRecord.connection.exec_insert(<<~SQL.squish)
      INSERT INTO incident_management_escalation_rules(
        policy_id,
        oncall_schedule_id,
        status,
        elapsed_time_seconds
      )
      SELECT
        incident_management_escalation_policies.id,
        incident_management_oncall_schedules.id,
        1,
        0
      FROM incident_management_escalation_policies
      INNER JOIN incident_management_oncall_schedules
        ON incident_management_escalation_policies.project_id = incident_management_oncall_schedules.project_id
      WHERE incident_management_escalation_policies.id IN (#{policy_ids.join(', ')})
      ORDER BY incident_management_escalation_policies.project_id, incident_management_oncall_schedules.id
    SQL
  end

  # There is no way to distinguish between policies created
  # via the backfill or as a result of a user creating a new
  # on-call schedule.
  def down
    # no-op
  end
end
