# frozen_string_literal: true

module Elastic
  class MigrationBatchWorker
    include ApplicationWorker

    feature_category :global_search
    urgency :throttled
    idempotent!

    def perform(version, name, filename)
      return false unless Gitlab::CurrentSettings.elasticsearch_indexing?
      return false unless helper.alias_exists?

      unless helper.index_exists?(index_name: helper.migrations_index_name)
        logger.info 'BatchMigrationWorker: creating migrations index'
        helper.create_migrations_index
      end

      migration = Elastic::MigrationRecord.new(version: version.to_i, name: name, filename: filename)
      return false if migration.completed?

      migration.migrate

      if migration.completed?
        logger.info "BatchMigrationWorker: migration[#{migration.name}] updating with completed: true"
        migration.save!(completed: true)
      else
        logger.info "BatchMigrationWorker: migration[#{migration.name}] kicking off another batch"
        Elastic::MigrationBatchWorker.perform_in(5.minutes, version, name, filename)
      end
    end

    private

    def helper
      Gitlab::Elastic::Helper.default
    end

    def logger
      @logger ||= ::Gitlab::Elasticsearch::Logger.build
    end
  end
end
