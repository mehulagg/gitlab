# frozen_string_literal: true

module RequirementsManagement
  class ImportCsvService < ::Issuable::ImportCsv::BaseService
    private

    def create_issuable_class
      RequirementsManagement::CreateRequirementService
    end

    def email_results_to_user
      Notify.import_requirements_csv_email(@user.id, @project.id, @results).deliver_later
    end
  end
end
