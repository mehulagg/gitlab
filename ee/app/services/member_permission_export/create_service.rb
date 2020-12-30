# frozen_string_literal: true

module MemberPermissionExport
  class CreateService
    def initialize(current_user)
      @current_user = current_user
    end

    def execute
      return ServiceResponse.error(message: _('Insufficient permissions')) unless allowed?

      jid = ::MemberPermissions::ExportWorker.perform_async(current_user.id, upload.id)

      if jid.present?
        ServiceResponse.success(message: _('Export in progress. You will receive an email soon with the link to download the report.'))
      else
        ServiceResponse.error(message: _('Failed to generate report. Please try again after sometime.'))
      end
    end

    private

    def allowed?
      current_user.can?(:export_user_permissions)
    end
  end
end
