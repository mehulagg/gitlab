# frozen_string_literal: true

class AddIncidentSlaTable < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :incident_slas, id: false  do |t|
      t.references :issue, primary_key: true, default: nil, index: true, foreign_key: { on_delete: :cascade }
      t.datetime_with_timezone :due_at, null: false
    end
  end
end
