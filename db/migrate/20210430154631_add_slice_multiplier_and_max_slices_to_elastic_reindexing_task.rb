# frozen_string_literal: true
class AddSliceMultiplierAndMaxSlicesToElasticReindexingTask < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  def change
    add_column :elastic_reindexing_tasks, :max_slices_running, :integer, limit: 2
    add_column :elastic_reindexing_tasks, :slice_multiplier, :integer, limit: 2
  end
end
