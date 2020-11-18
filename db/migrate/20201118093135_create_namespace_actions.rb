# frozen_string_literal: true

class CreateNamespaceActions < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      create_table :namespace_actions do |t|
        t.references :namespace, index: true, null: false, foreign_key: { on_delete: :cascade }
        t.integer :action, limit: 2, null: false
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :namespace_actions
    end
  end
end
