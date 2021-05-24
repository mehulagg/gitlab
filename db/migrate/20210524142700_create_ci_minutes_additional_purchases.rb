# frozen_string_literal: true

class CreateCiMinutesAdditionalPurchases < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    # https://docs.gitlab.com/ee/development/ordering_table_columns.html#real-example
    create_table_with_constraints :ci_minutes_additional_purchases, id: false, if_not_exists: true do |t|
      t.timestamps_with_timezone
      t.primary_key :id
      t.date        :expires_at, null: false
      t.references  :namespace, index: true, null: false, foreign_key: { on_delete: :cascade }
      t.integer     :number_of_minutes, null: false
      t.text        :purchase_id, null: false

      t.text_limit  :purchase_id, 255
    end

    add_concurrent_index :ci_minutes_additional_purchases, [:namespace_id, :purchase_id], name: 'i_ci_minutes_additional_purchases_on_namespace_id_purchase_id'
  end

  def down
    with_lock_retries do
      drop_table :ci_minutes_additional_purchases
    end
  end
end
