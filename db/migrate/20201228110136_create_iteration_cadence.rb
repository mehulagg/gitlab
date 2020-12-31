# frozen_string_literal: true

class CreateIterationCadence < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      unless table_exists?(:iteration_cadences)
        create_table :iteration_cadences do |t|
          t.references :group, null: false, foreign_key: { to_table: :namespaces, on_delete: :cascade }
          t.timestamps_with_timezone null: false
          t.date :start_date, null: false
          t.date :last_run_date
          t.integer :duration
          t.integer :iterations_in_advance
          t.boolean :active, default: true, null: false
          t.boolean :automatic, default: true, null: false
          t.text :title, null: false
        end
      end
    end

    add_text_limit :iteration_cadences, :title, 255
  end

  def down
    with_lock_retries do
      drop_table :iteration_cadences if table_exists?(:iteration_cadences)
    end
  end
end
