# frozen_string_literal: true

class AddProjectValueStreamIdToProjectStages < ActiveRecord::Migration[6.0]
  def up
    add_column :analytics_cycle_analytics_project_stages, :project_value_stream_id, :bigint
  end

  def down
    remove_column :analytics_cycle_analytics_project_stages, :project_value_stream_id
  end
end
