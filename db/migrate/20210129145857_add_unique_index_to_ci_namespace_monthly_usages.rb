# frozen_string_literal: true

class AddUniqueIndexToCiNamespaceMonthlyUsages < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  NAMESPACE_ID_AND_YEAR_MONTH = "namespace_id, DATE_TRUNC('month', created_at AT TIME ZONE 'UTC')"
  INDEX_NAME = "index_unique_ci_namespace_monthly_usages_on_year_and_month"

  disable_ddl_transaction!

  def up
    add_concurrent_index :ci_namespace_monthly_usages, NAMESPACE_ID_AND_YEAR_MONTH, unique: true, name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :ci_namespace_monthly_usages, INDEX_NAME
  end
end
