# frozen_string_literal: true

class AddTriggerToBulkSetIssueIid < ActiveRecord::Migration[6.0]
  include Gitlab::Database::SchemaHelpers

  DOWNTIME = false

  def up
    execute(<<~SQL)
      CREATE OR REPLACE FUNCTION fn_bulk_set_issues_iid()
      RETURNS trigger
      LANGUAGE plpgsql
      AS $$
        DECLARE row_count int;
        DECLARE target_project_id int;
        DECLARE last_generated_iid int;
      BEGIN
        SELECT COUNT(*) INTO row_count FROM inserted_rows;
        SELECT inserted_rows.project_id INTO target_project_id FROM inserted_rows LIMIT 1;

        INSERT INTO internal_ids
          (project_id, usage, last_value)
        VALUES
          (target_project_id, 0, row_count) -- issue usage enum value is 0
        ON CONFLICT (usage, project_id) WHERE project_id IS NOT NULL DO UPDATE
          SET last_value = internal_ids.last_value + row_count
        RETURNING last_value INTO last_generated_iid;

        UPDATE issues
        SET iid = mapped_iids.iid
        FROM (
          SELECT
            inserted.id,
            generated.iid
          FROM (
            SELECT
              row_number() OVER (ORDER BY id) AS row_number,
              inserted_rows.id AS id
            FROM inserted_rows
          ) AS inserted
          INNER JOIN (
            SELECT
              i AS row_number,
              (last_generated_iid - row_count + i) AS iid
            FROM generate_series(1, row_count) AS i
          ) AS generated
          ON inserted.row_number = generated.row_number
        ) AS mapped_iids
        WHERE issues.id = mapped_iids.id;

        RETURN NULL;
      END
      $$
    SQL

    execute(<<~SQL)
      CREATE TRIGGER tg_bulk_set_issues_iid
      AFTER INSERT ON issues
      REFERENCING NEW TABLE AS inserted_rows
      FOR EACH STATEMENT
      EXECUTE FUNCTION fn_bulk_set_issues_iid()
    SQL
  end

  def down
    drop_trigger(:issues, :tg_bulk_set_issues_iid, if_exists: false)
    drop_function(:fn_bulk_set_issues_iid, if_exists: false)
  end
end
