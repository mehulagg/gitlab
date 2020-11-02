# frozen_string_literal: true

module ElasticMigrations
  class InitialWorker
    include ApplicationWorker
    prepend Elastic::MigrationWorker

    feature_category :global_search
    idempotent!

    def perform
    end
  end
end
