# frozen_string_literal: true

class ScheduleLatestPipelineIdPopulation < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
  end

  def down
    # no-op
  end
end
