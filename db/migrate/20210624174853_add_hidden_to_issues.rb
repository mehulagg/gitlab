# frozen_string_literal: true

class AddHiddenToIssues < ActiveRecord::Migration[6.1]
  def up
    add_column :issues, :hidden, :boolean, default: false
  end

  def down
    remove_column :issues, :hidden
  end
end
