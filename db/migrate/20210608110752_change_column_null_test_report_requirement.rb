# frozen_string_literal: true

class ChangeColumnNullTestReportRequirement < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  TARGET_TABLE = :requirements_management_test_reports
  CONSTRAINT_NAME = 'requirements_test_reports_requirement_id_xor_issue_id'

  def up
    with_lock_retries do
      change_column_null TARGET_TABLE, :requirement_id, true
    end

    add_concurrent_foreign_key TARGET_TABLE, :issues, column: :issue_id

    add_check_constraint(TARGET_TABLE, 'num_nonnulls(requirement_id, issue_id) = 1', CONSTRAINT_NAME)
  end

  def down
    with_lock_retries do
      remove_foreign_key_if_exists(TARGET_TABLE, column: :issue_id)
    end

    # no change to null as it's difficult to revert
    remove_check_constraint TARGET_TABLE, CONSTRAINT_NAME
  end
end
