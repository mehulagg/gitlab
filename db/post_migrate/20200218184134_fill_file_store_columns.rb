# frozen_string_literal: true

class FillFileStoreColumns < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  class JobArtifact < ActiveRecord::Base
    include EachBatch

    self.table_name = 'ci_job_artifacts'

    BATCH_SIZE = 10_000

    def self.params_for_background_migration
      yield self.where(file_store: nil), 'FillFileStoreJobArtifact', 5.minutes, BATCH_SIZE
    end
  end

  class LfsObject < ActiveRecord::Base
    include EachBatch

    self.table_name = 'lfs_objects'

    BATCH_SIZE = 10_000

    def self.params_for_background_migration
      yield self.where(file_store: nil), 'FillFileStoreLfsObject', 5.minutes, BATCH_SIZE
    end
  end

  class Upload < ActiveRecord::Base
    include EachBatch

    self.table_name = 'uploads'
    self.inheritance_column = :_type_disabled # Disable STI

    BATCH_SIZE = 10_000

    def self.params_for_background_migration
      yield self.where(store: nil), 'FillStoreUpload', 5.minutes, BATCH_SIZE
    end
  end

  def up
    FillFileStoreColumns::JobArtifact.params_for_background_migration do |relation, class_name, delay_interval, batch_size|
      queue_background_migration_jobs_by_range_at_intervals(relation,
        class_name,
        delay_interval,
        batch_size: batch_size)
    end

    FillFileStoreColumns::LfsObject.params_for_background_migration do |relation, class_name, delay_interval, batch_size|
      queue_background_migration_jobs_by_range_at_intervals(relation,
        class_name,
        delay_interval,
        batch_size: batch_size)
    end

    FillFileStoreColumns::Upload.params_for_background_migration do |relation, class_name, delay_interval, batch_size|
      queue_background_migration_jobs_by_range_at_intervals(relation,
        class_name,
        delay_interval,
        batch_size: batch_size)
    end
  end

  def down
    # no-op
  end
end
