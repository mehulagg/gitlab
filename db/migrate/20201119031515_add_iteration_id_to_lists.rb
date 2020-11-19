# frozen_string_literal: true

class AddIterationIdToLists < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_reference :lists, :iteration, index: true, foreign_key: { on_delete: :cascade, to_table: :sprints }
  end
end
