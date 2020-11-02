# frozen_string_literal: true

class CreateEnvironmentEventsTable < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :environment_events do |t|
      t.timestamps_with_timezone
      t.references :project, index: true, null: false, foreign_key: { on_delete: :cascade }
      t.references :environment, index: true, null: false, foreign_key: { on_delete: :cascade }
      t.datetime_with_timezone :recorded_at, null: false
      t.text :subject_xid, null: false
      t.text :event_name, null: false
      t.integer :event_type, null: false, limit: 2
      t.text :event_output, null: false
    end
  end
end
