# frozen_string_literal: true

class AddBoardTypeIndex < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  NAME = 'index_boards_on_board_type'

  disable_ddl_transaction!

  def up
    add_concurrent_index :boards, :board_type, name: NAME
  end

  def down
    remove_concurrent_index :boards, :board_type, name: NAME
  end
end
