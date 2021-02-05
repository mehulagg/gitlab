# frozen_string_literal: true

class AddUniqueIndexToCiProjectMonthlyUsage < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  PROJECT_ID_AND_YEAR_MONTH = "project_id, DATE_TRUNC('month', created_at AT TIME ZONE 'UTC')"
  INDEX_NAME = "index_unique_ci_project_monthly_usages_on_year_and_month"

  disable_ddl_transaction!

  def up
    add_concurrent_index :ci_project_monthly_usages, PROJECT_ID_AND_YEAR_MONTH, unique: true, name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :ci_project_monthly_usages, INDEX_NAME
  end
end
