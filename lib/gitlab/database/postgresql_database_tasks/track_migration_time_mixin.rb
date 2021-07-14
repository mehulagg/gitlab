# frozen_string_literal: true

module Gitlab
  module Database
    module PostgresqlDatabaseTasks
      module TrackMigrationTimeMixin
        def exec_migration(...)
          ActiveRecord::SchemaMigration.migration_start_times[version] = Time.zone.now

          super(...)
        end
      end
    end
  end
end
