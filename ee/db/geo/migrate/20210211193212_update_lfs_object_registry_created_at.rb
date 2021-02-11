# frozen_string_literal: true

class UpdateLfsObjectRegistryCreatedAt < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  class LfsObjectRegistry < ActiveRecord::Base
    self.table_name = 'lfs_object_registry'
  end

  def up
    # rubocop: disable CodeReuse/ActiveRecord
    LfsObjectRegistry.where(created_at: nil).update_all(created_at: Time.now.utc)
  end

  def down
    # no-op
  end
end
