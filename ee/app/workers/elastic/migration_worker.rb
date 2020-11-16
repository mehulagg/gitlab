# frozen_string_literal: true

module Elastic
  class MigrationWorker
    include ApplicationWorker
    include Gitlab::ExclusiveLeaseHelpers
    # There is no onward scheduling and this cron handles work from across the
    # application, so there's no useful context to add.
    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

    feature_category :global_search
    idempotent!
    urgency :throttled

    def perform
      return false unless Gitlab::CurrentSettings.elasticsearch_indexing?
      return false unless helper.alias_exists?

      in_lock(self.class.name.underscore, ttl: 1.day, retries: 10, sleep_sec: 1) do
        migration = current_migration

        unless migration
          logger.info 'MigrationWorker: no migration available'
          break false
        end

        unless helper.index_exists?(index_name: helper.migrations_index_name)
          logger.info 'MigrationWorker: creating migrations index'
          helper.create_migrations_index
        end

        execute_migration(migration)

        completed = migration.completed?
        logger.info "MigrationWorker: migration[#{migration.name}] updating with completed: #{completed}"
        migration.save!(completed: completed)
      end
    end

    private

    def execute_migration(migration)
      if migration.persisted?
        logger.info "MigrationWorker: migration[#{migration.name}] did not execute migrate method since it was already executed. Waiting for migration to complete"
      else
        logger.info "MigrationWorker: migration[#{migration.name}] executing migrate method"
        migration.migrate
      end
    end

    def current_migration
      completed_migrations = Elastic::MigrationRecord.persisted_versions(completed: true)

      Elastic::DataMigrationService.migrations.find { |migration| !completed_migrations.include?(migration.version) }
    end

    def helper
      Gitlab::Elastic::Helper.default
    end

    def logger
      @logger ||= ::Gitlab::Elasticsearch::Logger.build
    end
  end
end
