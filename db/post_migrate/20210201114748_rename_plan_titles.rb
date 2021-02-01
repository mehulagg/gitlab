# frozen_string_literal: true

class RenamePlanTitles < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    execute "UPDATE plans SET title='Premium (Formerly Silver)' WHERE name='silver'"
    execute "UPDATE plans SET title='Ultimate (Formerly Gold)' WHERE name='gold'"
  end

  def down
    execute "UPDATE plans SET title='Silver' WHERE name='silver'"
    execute "UPDATE plans SET title='Gold' WHERE name='gold'"
  end
end
