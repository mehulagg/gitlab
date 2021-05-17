# frozen_string_literal: true

class GroupProtectedEnvironments < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  INDEX_NAME = 'index_group_protected_environments_on_group_id_and_tier'

  def change
    create_table_with_constraints :group_protected_environments do |t|
      t.timestamps_with_timezone null: false
      t.references :group, null: false, foreign_key: { to_table: :namespaces, on_delete: :cascade }
      t.integer :tier, null: false, limit: 2
      t.index [:group_id, :tier], unique: true, name: INDEX_NAME
    end
  end
end
