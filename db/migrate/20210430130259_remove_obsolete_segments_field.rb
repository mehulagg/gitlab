# frozen_string_literal: true

class RemoveObsoleteSegmentsField < ActiveRecord::Migration[6.0]
  def up
    remove_column :analytics_devops_adoption_segments, :name
  end

  def down
    add_column :analytics_devops_adoption_segments, :name, :string
  end
end
