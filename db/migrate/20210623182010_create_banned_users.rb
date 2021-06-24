# frozen_string_literal: true

class CreateBannedUsers < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_table :banned_users do |t|
      t.references :user, foreign_key: { on_delete: :cascade }, type: :integer, index: true
      t.integer :ban_state, limit: 2
      t.timestamps_with_timezone null: false
    end
  end

  def down
    drop_table :banned_users
  end
end
