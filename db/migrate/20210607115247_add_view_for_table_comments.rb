# frozen_string_literal: true

class AddViewForTableComments < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      CREATE VIEW postgres_table_comments AS
        SELECT
          nspname || '.' || relname as identifier,
          nspname as schema,
          relname,
          obj_description(pg_class.oid, 'pg_class') as comment
        FROM pg_class
        JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
        WHERE relkind = 'r'
          AND pg_namespace.nspname <> 'pg_catalog'::name AND (pg_namespace.nspname = ANY (ARRAY["current_schema"(), 'gitlab_partitions_dynamic'::name, 'gitlab_partitions_static'::name]))
          AND obj_description(pg_class.oid, 'pg_class') IS NOT NULL
    SQL
  end

  def down
    execute 'DROP VIEW postgres_table_comments'
  end
end
