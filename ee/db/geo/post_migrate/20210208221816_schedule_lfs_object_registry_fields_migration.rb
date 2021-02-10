# frozen_string_literal: true

class ScheduleLfsObjectRegistryFieldsMigration < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  class LfsObjectRegistry < ActiveRecord::Base
    self.table_name = 'lfs_object_registry'
  end

  def up
    LfsObjectRegistry.select(:id).eacg_batch do |lor|
      BackgroundMigrationWorker.bulk_migrate_async(lor)
    end
  end
end
