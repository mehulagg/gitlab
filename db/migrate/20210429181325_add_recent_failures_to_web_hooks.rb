# frozen_string_literal: true

class AddRecentFailuresToWebHooks < ActiveRecord::Migration[6.0]
  def up
    add_column(:web_hooks, :recent_failures, :integer, default: 0)
  end

  def down
    remove_column(:web_hooks, :recent_failures)
  end
end
