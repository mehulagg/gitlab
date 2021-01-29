# frozen_string_literal: true

class CreateCiNamespaceMonthlyUsage < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_table :ci_namespace_monthly_usages do |t|
      t.references :namespace, foreign_key: { on_delete: :cascade }, null: false
      t.integer :amount_used, null: false, default: 0
      t.integer :additional_amount_available, null: false, default: 0
      t.timestamps_with_timezone null: false
    end
  end

  def down
    drop_table :ci_namespace_monthly_usages
  end
end
