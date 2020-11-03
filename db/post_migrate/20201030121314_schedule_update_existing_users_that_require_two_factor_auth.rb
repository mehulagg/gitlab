# # frozen_string_literal: true

class ScheduleUpdateExistingUsersThatRequireTwoFactorAuth < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  MIGRATION = 'UpdateExistingUsersThatRequireTwoFactorAuth'
  DELAY_INTERVAL = 2.minutes
  BATCH_SIZE = 1000

  disable_ddl_transaction!

  class User < ActiveRecord::Base
    include EachBatch

    self.table_name = 'users'
  end

  def up
    relation = User.where(require_two_factor_authentication_from_group: true)

    queue_background_migration_jobs_by_range_at_intervals(
      relation, MIGRATION, DELAY_INTERVAL, batch_size: BATCH_SIZE)
  end

  def down
    # no-op
  end
end
