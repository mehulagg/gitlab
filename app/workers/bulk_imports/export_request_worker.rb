# frozen_string_literal: true

module BulkImports
  class ExportRequestWorker
    include ApplicationWorker

    idempotent!
    worker_has_external_dependencies!
    feature_category :importers

    def perform(entity_id)
      entity = BulkImports::Entity.find(entity_id)

      request_export(entity)
    end

    private

    def request_export(entity)
      configuration = entity.bulk_import.configuration
      encoded_full_path = ERB::Util.url_encode(entity.source_full_path)
      client = Clients::Http.new(uri: configuration.url, token: configuration.access_token)

      client.post("/groups/#{encoded_full_path}/export_relations")
    end
  end
end
