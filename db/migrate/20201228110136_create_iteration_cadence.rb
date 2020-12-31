# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateIterationCadence < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  INDEX_NAME = 'index_sprints_iteration_cadence_id'

  def up
    with_lock_retries do
      unless table_exists?(:iteration_cadences)
        create_table :iteration_cadences do |t|
          t.references :group, references: :namespaces, index: true, null: false,
            foreign_key: { to_table: :namespaces, on_delete: :cascade }
          t.integer :duration
          t.integer :iterations_in_advance
          t.boolean :is_active, default: true, null: false
          t.boolean :automatic, default: true, null: false
          t.text :title, null: false
          t.timestamps_with_timezone null: false
          t.datetime_with_timezone :start_date
          t.datetime_with_timezone :next_run_date
        end
      end

      add_column :sprints, :iteration_cadence_id, :integer unless column_exists?(:sprints, :iteration_cadence_id)
    end

    add_text_limit :iteration_cadences, :title, 255
    add_concurrent_index :sprints, :iteration_cadence_id, name: INDEX_NAME
    add_concurrent_foreign_key :sprints, :iteration_cadences, column: :iteration_cadence_id, on_delete: :cascade
  end

  def down
    remove_foreign_key_if_exists :sprints, :iteration_cadence
    remove_concurrent_index_by_name :sprints, INDEX_NAME

    with_lock_retries do
      drop_table :iteration_cadences if table_exists?(:iteration_cadences)

      remove_column :iteration_cadences, :iteration_cadence_id if column_exists?(:sprints, :iteration_cadence_id)
    end
  end
end
