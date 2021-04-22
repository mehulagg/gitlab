# frozen_string_literal: true

module BulkImports
  class ExportService
    attr_reader :exportable, :current_user

    def initialize(exportable:, user:)
      @exportable = exportable
      @current_user = user
    end

    def execute
      ::Gitlab::ImportExport.top_level_relations(exportable.class.name).each do |relation|
        RelationExportWorker.perform_async(current_user.id, exportable.id, exportable.class.name, relation)
      end

      ServiceResponse.success
    rescue => e
      ServiceResponse.error(
        message: e.class,
        http_status: :unprocessable_entity
      )
    end
  end
end
