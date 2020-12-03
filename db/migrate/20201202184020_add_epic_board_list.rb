# frozen_string_literal: true

class AddEpicBoardList < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :boards_epic_lists do |t|
        t.references :epic_board, index: true, foreign_key: { to_table: :boards_epic_boards, on_delete: :cascade }, null: false
        t.references :label, index: true, foreign_key: { on_delete: :cascade }, null: false
        t.integer :position
        t.integer :list_type, default: 1
        t.timestamps_with_timezone
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :boards_epic_lists
    end
  end
end
