# frozen_string_literal: true

module RequirementsManagement
  class ImportCsvService < ::Issuable::ImportCsv::BaseService
    private

    def create_issuable_class
      RequirementsManagement::CreateRequirementService
    end
  end
end
