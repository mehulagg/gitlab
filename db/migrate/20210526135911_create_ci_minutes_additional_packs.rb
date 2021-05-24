# frozen_string_literal: true

class CreateCiMinutesAdditionalPacks < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    create_table_with_constraints :ci_minutes_additional_packs, if_not_exists: true do |t|
      t.timestamps_with_timezone
      t.date        :expires_at, null: true
      t.references  :namespace, index: true, null: false, foreign_key: { on_delete: :cascade }
      t.integer     :number_of_minutes, null: false
      t.text        :purchase_xid, null: true
      t.text_limit  :purchase_xid, 32
    end

    add_concurrent_index :ci_minutes_additional_packs, [:namespace_id, :purchase_xid], name: 'index_ci_minutes_additional_packs_on_namespace_id_purchase_xid'
  end

  def down
    with_lock_retries do
      drop_table :ci_minutes_additional_packs
    end
  end
end
