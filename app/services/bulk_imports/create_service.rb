# frozen_string_literal: true

module BulkImports
  class CreateService
    def initialize(current_user, params, credentials)
      @current_user = current_user
      @params = params
      @credentials = credentials
    end

    def execute
      bulk_import = create_bulk_import

      BulkImportWorker.perform_async(bulk_import.id)

      ServiceResponse.success(payload: bulk_import)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResponse.error(
        message: e.message,
        http_status: :unprocessable_entity
      )
    end

    private

    attr_reader :current_user, :params, :credentials

    def create_bulk_import
      BulkImport.transaction do
        bulk_import = BulkImport.create!(user: current_user, source_type: 'gitlab')
        bulk_import.create_configuration!(credentials.slice(:url, :access_token))

        params.each do |entity_params|
          BulkImports::CreateEntityService
            .new(bulk_import, entity_params)
            .execute
        end

        bulk_import
      end
    end
  end
end
