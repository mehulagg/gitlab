# frozen_string_literal: true

class AddAvailabilityToUserStatuses < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :user_statuses, :availability, :integer, limit: 2
  end
end
