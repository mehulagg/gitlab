# frozen_string_literal: true

module Members
  class PermissionsExportService
    include Gitlab::Utils::StrongMemoize
    TARGET_FILESIZE = 15.megabytes

    def initialize(current_user)
      @current_user = current_user
    end

    def csv_data
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      ServiceResponse.success(payload: csv_builder.render(TARGET_FILESIZE)) #change to use async menthod
    end

    private

    attr_reader :current_user

    def allowed?
      current_user.can?(:export_user_permissions)
    end

    def csv_builder
      @csv_builder ||= CsvBuilder.new(data, header_to_value_hash)
    end

    def data
      Member.includes(:user, source: [children: :route])
    end

    def header_to_value_hash
      {
        'Username' => -> (member) { member.user&.username },
        'Email' => -> (member) { member.user&.email },
        'Type' => 'source_type',
        'Path' => -> (member) { member.source&.path },
        'Access Level' => -> (member) { member.human_access },
        'Inherited memberships' => -> (member) { member.source.children.map(&:full_path).join('|') if member.source_type == 'Namespace' }
      }
    end
  end
end
