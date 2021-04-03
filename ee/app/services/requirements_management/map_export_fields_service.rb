# frozen_string_literal: true

module RequirementsManagement
  class MapExportFieldsService < BaseService
    attr_reader :fields

    def initialize(fields)
      @fields = fields
    end

    def execute
      return header_to_value_hash if fields.empty?

      selected_fields_to_hash
    end

    def invalid_fields
      fields.reject { |field| permitted_field?(field) }
    end

    private

    def header_to_value_hash
      @header_to_value_hash ||= {
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

    def selected_fields_to_hash
      header_to_value_hash.select { |key| requested_field?(key) }
    end

    def requested_field?(field)
      field.downcase.in?(fields.map(&:downcase))
    end

    def permitted_field?(field)
      field.downcase.in?(keys.map(&:downcase))
    end

    def keys
      header_to_value_hash.keys
    end
  end
end
