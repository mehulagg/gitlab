# frozen_string_literal: true

class CreateExperimentSubjects < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :experiment_subjects do |t|
      t.references :experiment, index: true, foreign_key: { on_delete: :cascade }, null: false
      t.bigint :user_id, index: true
      t.bigint :group_id, index: true
      t.bigint :project_id, index: true
      t.smallint :variation, limit: 2, null: false, default: 0
      t.datetime_with_timezone :converted_at
      t.timestamps_with_timezone null: false
    end
  end

  #
  # In next three migrations:
  #

  # include Gitlab::Database::MigrationHelpers

  # DOWNTIME = false

  # def up
  #   with_lock_retries do
  #     # There is no need to use add_concurrent_foreign_key since it's an empty table
  #     add_foreign_key :experiment_subjects, :users, column: :user_id, on_delete: :cascade
  #   end
  # end

  # def down
  #   with_lock_retries do
  #     remove_foreign_key :experiment_subjects, column: :user_id
  #   end
  # end
end
