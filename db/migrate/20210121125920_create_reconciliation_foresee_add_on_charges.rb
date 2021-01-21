class CreateReconciliationForeseeAddOnCharges < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      create_table :reconciliation_foresee_add_on_charges do |t|
        t.string :namespace_id
        t.integer :days_before_reconcil

        t.timestamps
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :reconciliation_foresee_add_on_charges
    end
  end

  def change
  end
end
