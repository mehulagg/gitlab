# frozen_string_literal: true

class AddStateToMembers < ActiveRecord::Migration[6.1]
  def up
    add_column :members, :state, :integer, limit: 2, default: 0
  end

  def down
    remove_column :members, :state
  end
end
