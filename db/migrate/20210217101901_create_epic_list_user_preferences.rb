# frozen_string_literal: true

class CreateEpicListUserPreferences < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :boards_epic_list_user_preferences do |t|
      t.references :user, index: true, null: false, foreign_key: { on_delete: :cascade }
      t.references :epic_list, index: true, null: false, foreign_key: { to_table: :boards_epic_lists, on_delete: :cascade }
      t.timestamps_with_timezone null: false
      t.boolean :collapsed, null: false, default: false
    end

    add_concurrent_index :boards_epic_list_user_preferences, [:user_id, :epic_list_id], unique: true, name: 'index_epic_board_list_preferences_on_user_and_list'
  end

  def down
    drop_table :boards_epic_list_user_preferences
  end
end
