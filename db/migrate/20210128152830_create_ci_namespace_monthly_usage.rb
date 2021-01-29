# frozen_string_literal: true

class CreateCiNamespaceMonthlyUsage < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :ci_namespace_monthly_usages, if_not_exists: true do |t|
        t.references :namespace, foreign_key: { on_delete: :cascade }, index: false, null: false
        t.timestamps_with_timezone null: false
        t.float :amount_used, null: false, default: 0.0
        t.integer :additional_amount_available, null: false, default: 0
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :ci_namespace_monthly_usages
    end
  end
end
