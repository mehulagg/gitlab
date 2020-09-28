# frozen_string_literal: true

module AuditEvents
  class ExportCsvService
    TARGET_FILESIZE = 15.megabytes

    def initialize(params = {})
      @params = params
    end

    def csv_data
      csv_builder.render(TARGET_FILESIZE)
    end

    private

    def csv_builder
      @csv_builder ||= CsvBuilder.new(data, header_to_value_hash)
    end

    def data
      AuditLogFinder.new(**finder_params).execute
    end

    def finder_params
      {
        level: Gitlab::Audit::Levels::Instance.new,
        params: @params
      }
    end

    def header_to_value_hash
      {
        'ID' => 'id',
        'Author ID' => 'author_id',
        'Author Name' => 'author_name_snapshot',
        'Entity ID' => 'entity_id',
        'Entity Type' => 'entity_type',
        'Entity Path' => 'entity_path',
        'Target ID' => 'target_id',
        'Target Type' => 'target_type',
        'Target Details' => 'target_details',
        'Action' => -> (event) { Audit::Details.humanize(event.details) },
        'IP Address' => 'ip_address',
        'Created At (UTC)' => -> (event) { event.created_at.utc.iso8601 }
      }
    end
  end
end
