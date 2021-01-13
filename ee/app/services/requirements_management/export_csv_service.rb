# frozen_string_literal: true

module RequirementsManagement
  class ExportCsvService < ::Issuable::ExportCsv::BaseService
    def email(user)
      Notify.requirements_csv_email(user, project, csv_data, csv_builder.status).deliver_now
    end

    private

    def associations_to_preload
      %i(author test_reports)
    end

    def header_to_value_hash
      {
        'Requirement ID' => 'iid',
        'Title' => 'title',
        'Description' => 'description',
        'Author Username' => -> (requirement) { requirement.author&.username },
        'Latest Test Report State' => -> (requirement) { requirement.last_test_report_state },
        'Latest Test Report Created At (UTC)' => -> (requirement) { latest_test_report_time(requirement) }
      }
    end

    def latest_test_report_time(requirement)
      requirement.test_reports.last&.created_at
    end
  end
end
