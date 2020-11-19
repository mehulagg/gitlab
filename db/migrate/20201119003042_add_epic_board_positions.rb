# frozen_string_literal: true

class AddEpicBoardPositions < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :epic_board_positions do |t|
        t.references :board, foreign_key: { on_delete: :cascade }, null: false, index: false
        t.references :epic, foreign_key: { on_delete: :cascade }, null: false, index: false
        t.integer :relative_position

        t.timestamps_with_timezone null: false
      end
    end

    add_concurrent_index :epic_board_positions, [:epic_id, :board_id], unique: true
  end

  def down
    drop_table :epic_board_positions
  end
end
