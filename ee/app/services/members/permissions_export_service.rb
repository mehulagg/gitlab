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

      ServiceResponse.success
    end

    private

    attr_reader :current_user

    def allowed?
      current_user.can?(:export_user_permissions)
    end
  end
end
