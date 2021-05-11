# frozen_string_literal: true

class BackfillClustersIntegrationElasticStackEnabled < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    ApplicationRecord.connection.execute(<<~SQL.squish)
      WITH executed_at AS (VALUES (TIMEZONE('UTC', NOW())))
      INSERT INTO clusters_integration_elastic_stack(
        cluster_id,
        enabled,
        chart_version,
        created_at,
        updated_at
      )
        SELECT
          cluster_id,
          true,
          version,
          (table executed_at),
          (table executed_at)
        FROM clusters_applications_elastic_stack
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
