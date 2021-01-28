# frozen_string_literal: true

class ExampleBackgroundMigration < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  JOB_CLASS_NAME = 'Gitlab::BackgroundMigration::CopyColumnUsingBackgroundMigrationJob'
  BATCH_RANGES = [
    [1, 100],
    [101, 200],
    [201, 300],
    [301, nil]
  ].freeze

  def up
    add_column :events, :id_convert_to_bigint, :bigint

    BATCH_RANGES.each_with_index do |(min, max), i|
      queue_batched_background_migration JOB_CLASS_NAME, :events, :id, job_interval: 2.minutes,
        batch_min_value: min, batch_max_value: max, batch_size: 50, sub_batch_size: 10,
        other_job_arguments: %w[id id_convert_to_bigint]
    end
  end

  def down
    abort_batched_background_migrations JOB_CLASS_NAME, :events, :id

    remove_column :events, :id_convert_to_bigint
  end
end
