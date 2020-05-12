# frozen_string_literal: true

class AddIntegrationsView < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  DOWNTIME = false

  def up
    # Should this be in a transaction?
    execute <<~SQL
      CREATE FUNCTION jsonb_merge_accum (jsonb, jsonb)
      RETURNS jsonb AS
      $$
      SELECT $1 || $2;
      $$ LANGUAGE 'sql' STRICT;

      CREATE AGGREGATE jsonb_merge(jsonb) ( INITCOND = '{}', STYPE = jsonb, SFUNC = jsonb_merge_accum );

      CREATE VIEW integrations
      AS
        WITH
        -- Start from highest level and go all the way down to the lowest level
        recursive recursive_services AS (
          SELECT *, integration_properties AS settings FROM services_with_parent WHERE parent_id IS NULL
          UNION ALL
          SELECT services_with_parent.*, jsonb_merge_accum(recursive_services.integration_properties, services_with_parent.integration_properties) AS settings FROM recursive_services JOIN services_with_parent ON recursive_services.id = services_with_parent.parent_id
        ),
        services_with_parent AS (
          SELECT
            services.id,
            services.project_id,
            services.group_id,
            services.integration_properties,
            -- This is needed so we can use a new model like EmailsOnPushIntegration to read from the view
            regexp_replace(services.type, 'Service', 'Integration') as type,
            -- If the highest level is reached, parent_id will be equal to id so it needs to be set to NULL
            NULLIF(COALESCE(parent.id,instance.id), services.id) AS parent_id
          FROM services
          LEFT JOIN projects project ON services.project_id = project.id
          LEFT JOIN namespaces groupo ON project.namespace_id = groupo.id
          -- Set group.id to -1 if NULL to avoud matching NULL = NULL
          LEFT JOIN services parent ON services.type = parent.type AND CASE WHEN groupo.type IS NULL THEN -1 ELSE groupo.id END = parent.group_id
          LEFT JOIN services instance ON services.type = instance.type AND instance.instance IS TRUE
        )
      SELECT * FROM recursive_services;
    SQL
  end

  def down
    # Should this be in a transaction?
    execute <<~SQL
      DROP VIEW integrations;
      DROP AGGREGATE jsonb_merge(jsonb);
      DROP FUNCTION jsonb_merge_accum(jsonb, jsonb);
    SQL
  end
end
