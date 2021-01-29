# frozen_string_literal: true

class AddUniqueIndexToCiNamespaceMonthlyUsages < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  EXTRACT_YEAR_MONTH = "DATE_TRUNC('month', created_at AT TIME ZONE 'UTC')".freeze

  disable_ddl_transaction!

  def up
    add_concurrent_index :ci_namespace_monthly_usages, EXTRACT_YEAR_MONTH, unique: true, name: 'index_unique_ci_namespace_monthly_usages_on_year_and_month'
  end

  def down
    remove_concurrent_index_by_name :ci_namespace_monthly_usages, 'index_unique_ci_namespace_monthly_usages_on_year_and_month'
  end
end
