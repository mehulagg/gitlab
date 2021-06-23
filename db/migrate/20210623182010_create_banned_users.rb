# frozen_string_literal: true

class CreateBannedUsers < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  def up
    create_table :banned_users do |t|
      t.integer :user_id
      t.integer :ban_state, limit: 2
      t.timestamps_with_timezone null: false
    end

    with_lock_retries do
      add_foreign_key(:banned_users, :users, column: :user_id, on_delete: :cascade)
    end
  end

  def down
    drop_table :banned_users
    remove_foreign_key_if_exists :banned_users, :users
  end
end
