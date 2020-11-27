# frozen_string_literal: true

class AddEpicBoards < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :epic_boards do |t|
        t.references :group, index: true, foreign_key: { to_table: :namespaces, on_delete: :cascade }, null: false
        t.boolean :hide_backlog_list, default: false, null: false
        t.boolean :hide_closed_list, default: false, null: false
        t.timestamps_with_timezone
        t.text :name, default: 'Development'
      end
    end

    add_text_limit :epic_boards, :name, 255
  end

  def down
    with_lock_retries do
      drop_table :epic_boards
    end
  end
end
