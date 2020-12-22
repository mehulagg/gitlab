# frozen_string_literal: true

class AddBoardType < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    add_column :boards, :board_type, :integer, limit: 2, default: 0, null: false
  end

  def down
    remove_column :boards, :board_type
  end
end
