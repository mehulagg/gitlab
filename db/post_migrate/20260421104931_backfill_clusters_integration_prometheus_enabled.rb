# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class BackfillClustersIntegrationPrometheusEnabled < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    ApplicationRecord.connection.execute(<<~SQL.squish)
      WITH executed_at AS (VALUES (TIMEZONE('UTC', NOW())))
      INSERT INTO clusters_integration_prometheus(
        cluster_id,
        enabled,
        encrypted_alert_manager_token,
        encrypted_alert_manager_token_iv,
        created_at,
        updated_at
      )
        SELECT
          cluster_id,
          true,
          encrypted_alert_manager_token,
          encrypted_alert_manager_token_iv,
          (table executed_at),
          (table executed_at)
        FROM clusters_applications_prometheus
        WHERE status IN (3, 11)
      ON CONFLICT(cluster_id) DO UPDATE SET
        enabled = true,
        updated_at = (table executed_at)
    SQL
  end

  def down
    # Irreversible
  end
end
