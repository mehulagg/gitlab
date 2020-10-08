# frozen_string_literal: true

class AddFeaturesToCiRunner < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :ci_runners, :executor, :string, limit: 255
    add_column :ci_runners, :features, :jsonb
  end
end
