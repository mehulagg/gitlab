# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateIncidentManagementPendingAlertEscalations < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  def up
    with_lock_retries do
      execute(<<~SQL)

        CREATE TABLE incident_management_pending_alert_escalations (
          id bigserial NOT NULL,
          rule_id bigint NOT NULL,
          alert_id bigint NOT NULL,
          schedule_id bigint NOT NULL,
          status smallint NOT NULL,
          process_at timestamp with time zone NOT NULL,
          created_at timestamp with time zone NOT NULL,
          updated_at timestamp with time zone NOT NULL,
          PRIMARY KEY (id, process_at)
        ) PARTITION BY RANGE (process_at);

        CREATE INDEX index_incident_management_pending_alert_escalations_on_alert_id
          ON incident_management_pending_alert_escalations USING btree (alert_id);

        CREATE INDEX index_incident_management_pending_alert_escalations_on_rule_id
          ON incident_management_pending_alert_escalations USING btree (rule_id);

        CREATE INDEX index_incident_management_pending_alert_escalations_on_process_at
          ON incident_management_pending_alert_escalations USING btree (process_at);

        ALTER TABLE incident_management_pending_alert_escalations ADD CONSTRAINT fk_rails_fcbfd9338b
          FOREIGN KEY (schedule_id) REFERENCES incident_management_oncall_schedules(id) ON DELETE CASCADE;

        ALTER TABLE incident_management_pending_alert_escalations ADD CONSTRAINT fk_rails_057c1e3d87
          FOREIGN KEY (rule_id) REFERENCES incident_management_escalation_rules(id) ON DELETE SET NULL;

        ALTER TABLE incident_management_pending_alert_escalations ADD CONSTRAINT fk_rails_8d8de95da9
          FOREIGN KEY (alert_id) REFERENCES alert_management_alerts(id) ON DELETE CASCADE;
      SQL
    end
  end

  def down
    with_lock_retries do
      drop_table :incident_management_pending_alert_escalations
    end
  end
end
