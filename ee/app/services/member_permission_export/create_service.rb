# frozen_string_literal: true

module MemberPermissionExport
  class CreateService
    def initialize(current_user)
      @current_user = current_user
    end

    def execute
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      upload = current_user.user_permission_export_uploads.create
      ::MemberPermissions::ExportWorker.perform_async(current_user.id, upload.id)

      upload
    end

    private

    def allowed?
      current_user.can?(:export_user_permissions)
    end
  end
end
