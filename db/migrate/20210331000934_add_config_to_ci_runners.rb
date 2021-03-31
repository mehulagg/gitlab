# frozen_string_literal: true

class AddConfigToCiRunners < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :ci_runners, :config, :jsonb, default: {}, null: false
  end
end
