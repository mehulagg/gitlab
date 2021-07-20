# frozen_string_literal: true

class AddRepeatsToDastProfileSchedules < ActiveRecord::Migration[6.1]
  def change
    add_column :dast_profile_schedules, :repeats, :boolean, null: false, default: true
  end
end
