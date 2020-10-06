# frozen_string_literal: true

module BulkImport
  class ImportService
    attr_reader :current_user, :params, :credentials

    def initialize(current_user, params, credentials)
      @current_user = current_user
      @params = params
      @credentials = credentials
    end

    def execute
      # Create BulkImport object based on user id
      # Create import entities based on params
      # create import configuration based on credentials

      Gitlab::BulkImport::ImportWorker.perform_async(bulk_import.id)
    end
  end
end
