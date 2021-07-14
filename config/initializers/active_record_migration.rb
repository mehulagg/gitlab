# frozen_string_literal: true

# Patch to track start times of migrations
ActiveRecord::Migration.prepend(Gitlab::Database::PostgresqlDatabaseTasks::TrackMigrationTimeMixin)

class ActiveRecord::SchemaMigration
  class << self
    def migration_start_times
      @migration_start_times ||= {}
    end
  end

  before_create do
    self.started_at = self.class.migration_start_times[version]
  end
end
