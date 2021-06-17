# frozen_string_literal: true

module BulkImports
  class ImportsFinder
    def initialize(user, status)
      @user = user
      @status = ::BulkImport.machine_status(status)
    end

    def execute
      filter_by_status(user.bulk_imports)
    end

    private

    attr_reader :user, :status

    def filter_by_status(imports)
      if status
        imports.with_status(status)
      else
        imports
      end
    end
  end
end
