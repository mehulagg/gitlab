# frozen_string_literal: true

module RequirementsManagement
  class ExportCsvService < ::Issuable::ExportCsv::BaseService
    PERMITTED_FIELDS = [
      'Requirement ID',
      'Title',
      'Description',
      'Author',
      'Author Username',
      'Created At (UTC)',
      'State',
      'State Updated At (UTC)'
    ].freeze

    def email(user)
      Notify.requirements_csv_email(user, project, csv_data, csv_builder.status).deliver_now
    end

    private

    def associations_to_preload
      %i(author test_reports)
    end

    def header_to_value_hash
      return all_fields_hash if fields.empty?

      selected_fields_hash(fields)
    end

    def selected_fields_hash(fields)
      all_fields_hash.keep_if { |key| fields.map(&:downcase).include?(key.to_s.downcase) }
    end

    def all_fields_hash
      {
        'Requirement ID' => 'iid',
        'Title' => 'title',
        'Description' => 'description',
        'Author' => -> (requirement) { requirement.author&.name },
        'Author Username' => -> (requirement) { requirement.author&.username },
        'Created At (UTC)' => -> (requirement) { requirement.created_at.utc },
        'State' => -> (requirement) { requirement.last_test_report_state == 'passed' ? 'Satisfied' : '' },
        'State Updated At (UTC)' => -> (requirement) { requirement.latest_report&.created_at&.utc }
      }
    end
  end
end
