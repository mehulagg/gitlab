# frozen_string_literal: true

class ChangeColumnNullTestReportRequirement < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  def up
    with_lock_retries do
      change_column_null :requirements_management_test_reports, :requirement_id, true
    end
  end

  def down
    with_lock_retries do
      change_column_null :requirements_management_test_reports, :requirement_id, false
    end
  end
end
