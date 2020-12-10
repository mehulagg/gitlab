# frozen_string_literal: true

class AddTriggerToSetIssueIid < ActiveRecord::Migration[6.0]
  include Gitlab::Database::SchemaHelpers

  DOWNTIME = false

  def up
    execute(<<~SQL)
      CREATE OR REPLACE FUNCTION fn_set_issues_iid()
      RETURNS trigger
      LANGUAGE plpgsql
      AS $$
      DECLARE
        generated_iid int;
      BEGIN
        INSERT INTO internal_ids
          (project_id, usage, last_value)
        VALUES
          (NEW.project_id, 0, 0) -- issue usage enum value is 0
        ON CONFLICT (usage, project_id) WHERE project_id IS NOT NULL DO UPDATE
          SET last_value = internal_ids.last_value + 1
        RETURNING last_value INTO generated_iid;

        RAISE NOTICE 'generated_iid is %', generated_iid;

        NEW.iid := generated_iid;

        RETURN NEW;
      END
      $$
    SQL

    create_trigger(:issues, :tg_set_issues_id, :fn_set_issues_iid, fires: 'BEFORE INSERT')
  end

  def down
    drop_trigger(:issues, :tg_set_issues_id, if_exists: false)
    drop_function(:fn_set_issues_iid, if_exists: false)
  end
end
