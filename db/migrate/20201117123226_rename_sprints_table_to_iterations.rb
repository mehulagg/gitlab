# frozen_string_literal: true

class RenameSprintsTableToIterations < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    rename_table(:sprints, :iterations)
  end
end
