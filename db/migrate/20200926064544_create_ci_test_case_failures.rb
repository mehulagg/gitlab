# frozen_string_literal: true

class CreateCiTestCaseFailures < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :ci_test_cases do |t|
      t.bigint :project_id, null: false
      t.text :key_hash, null: false

      t.index [:project_id, :key_hash], unique: true
      # NOTE: FK for projects will be added on a separate migration as per guidelines
    end

    add_text_limit :ci_test_cases, :key_hash, 64

    create_table :ci_test_case_failures do |t|
      t.datetime_with_timezone :failed_at
      t.bigint :test_case_id, null: false
      t.bigint :build_id, null: false

      # ref_path has no limit for backward compatibility with existing ref columns
      t.text :ref_path, null: false # rubocop:disable Migration/AddLimitToTextColumns

      t.index [:test_case_id, :failed_at, :ref_path, :build_id], name: 'index_test_case_failures_unique_columns', unique: true, order: { failed_at: :desc }
      t.index :build_id
      t.foreign_key :ci_test_cases, column: :test_case_id, on_delete: :cascade
      # NOTE: FK for ci_builds will be added on a separate migration as per guidelines
    end
  end

  def down
    drop_table :ci_test_case_failures
    drop_table :ci_test_cases
  end
end
