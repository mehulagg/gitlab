# frozen_string_literal: true

class ChangeIterationDateRangeConstraint < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    execute <<~SQL
      ALTER TABLE sprints
        DROP CONSTRAINT IF EXISTS iteration_start_and_due_daterange_group_id_constraint
    SQL

    execute <<~SQL
      ALTER TABLE sprints
        ADD CONSTRAINT iteration_start_and_due_date_iteration_cadence_id_constraint
        EXCLUDE USING gist
        ( iteration_cadence_id WITH =,
          daterange(start_date, due_date, '[]') WITH &&
        )
        WHERE (group_id IS NOT NULL)
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE sprints
        DROP CONSTRAINT IF EXISTS iteration_start_and_due_date_iteration_cadence_id_constraint
    SQL

    execute <<~SQL
      ALTER TABLE sprints
        ADD CONSTRAINT iteration_start_and_due_daterange_group_id_constraint
        EXCLUDE USING gist
        ( group_id WITH =,
          daterange(start_date, due_date, '[]') WITH &&
        )
        WHERE (group_id IS NOT NULL)
    SQL
  end
end
