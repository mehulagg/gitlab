# frozen_string_literal: true

module MemberPermissionExport
  class ExportService
    FILESIZE_LIMIT = 15.megabytes

    def initialize(current_user, upload)
      @current_user = current_user
      @upload = upload
    end

    def export
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      upload.start!
      generate_csv_data
      send_mail
      upload.finish!

      ServiceResponse.success
    rescue StandardError => e
      upload.failed!

      ServiceResponse.error(message: "Failed to export user permissions: #{e.message}")
    ensure
      schedule_export_deletion
    end

    private

    attr_reader :current_user, :upload

    def allowed?
      current_user.can?(:export_user_permissions)
    end

    def generate_csv_data
      csv_builder.render(FILESIZE_LIMIT) { |f| upload.file = f }
      upload.file.filename = filename
    end

    def csv_builder
      @csv_builder ||= CsvBuilder.new(data, header_to_value_hash)
    end

    def data
      Member
        .active_without_invites_and_requests
        .with_csv_entity_associations
    end

    def header_to_value_hash
      {
        'Username' => 'user_username',
        'Email' => 'user_email',
        'Type' => 'source_kind',
        'Path' => -> (member) { member.source&.full_path },
        'Access Level' => 'human_access'
      }
    end

    def filename
      [
        'user_permissions_export_',
        Time.current.utc.strftime('%FT%H%M'),
        '.csv'
      ].join
    end

    def send_mail

    end

    def schedule_export_deletion
      # to do
    end
  end
end
