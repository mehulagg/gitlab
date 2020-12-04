# frozen_string_literal: true

module BulkImports
  class ProcessEntityWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    feature_category :importers

    sidekiq_options retry: false, dead: false

    worker_has_external_dependencies!

    def perform(entity_id)
      @entity = BulkImports::Entity.find(entity_id)

      BulkImports::Importers::GroupImporter.new(@entity).execute
    end
  end
end
