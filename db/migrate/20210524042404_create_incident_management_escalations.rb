
# frozen_string_literal: true

class CreateIncidentManagementEscalations < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  def up
    with_lock_retries do
      execute(<<~SQL)
        CREATE TABLE incident_management_alert_escalations (
          id bigserial NOT NULL,
          policy_id bigint NOT NULL,
          alert_id bigint NOT NULL,
          last_notified_at timestamp with time zone,
          created_at timestamp with time zone NOT NULL,
          updated_at timestamp with time zone NOT NULL,
          PRIMARY KEY (id, created_at)
        ) PARTITION BY RANGE (created_at);

        CREATE INDEX index_incident_management_alert_escalations_on_alert_id
          ON incident_management_alert_escalations USING btree (alert_id);

        CREATE INDEX index_incident_management_alert_escalations_on_policy_id
          ON incident_management_alert_escalations USING btree (policy_id);

        ALTER TABLE incident_management_alert_escalations ADD CONSTRAINT fk_rails_bc0826ee7d
          FOREIGN KEY (policy_id) REFERENCES incident_management_escalation_policies(id) ON DELETE CASCADE;

        ALTER TABLE incident_management_alert_escalations ADD CONSTRAINT fk_rails_8d8de95da9
          FOREIGN KEY (alert_id) REFERENCES alert_management_alerts(id) ON DELETE CASCADE;
      SQL
    end
  end

  def down
    with_lock_retries do
      drop_table :incident_management_alert_escalations
    end
  end
end
