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
        'Created By' => -> (requirement) { requirement.author&.username },
        'Created Date' => -> (requirement) { requirement.created_at },
        'Satisfied / Failed State' => -> (requirement) { latest_test_report_state(requirement) },
        'Satisfied / Failed Date' => -> (requirement) { latest_test_report_date(requirement) }
      }
    end

    def latest_test_report_state(requirement)
      return 'Satisfied' if requirement.last_test_report_state == 'passed'

      requirement.last_test_report_state&.capitalize
    end

    def latest_test_report_date(requirement)
      requirement.test_reports.last&.created_at
    end
  end
end
