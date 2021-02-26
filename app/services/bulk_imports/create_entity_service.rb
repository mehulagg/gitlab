# frozen_string_literal: true

module BulkImports
  class CreateEntityService
    def initialize(bulk_import, params)
      @bulk_import = bulk_import
      @params = params
    end

    def execute
      create_entity!
      BulkImportWorker.perform_async(bulk_import)
    end

    private

    attr_reader :bulk_import, :params

    def create_entity!
      bulk_import.entities.create!(
        source_type: params[:source_type],
        source_full_path: params[:source_full_path],
        destination_name: params[:destination_name],
        destination_namespace: params[:destination_namespace]
      )
    end
  end
end
