# frozen_string_literal: true

class RemoveIterationGroupDateRangeConstraint < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      execute <<~SQL
        ALTER TABLE sprints
          DROP CONSTRAINT IF EXISTS iteration_start_and_due_daterange_group_id_constraint
      SQL
    end
  end

  def down
    with_lock_retries do
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
end
