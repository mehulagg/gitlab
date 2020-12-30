# frozen_string_literal: true

class UserPermissionExportWorker
  include ApplicationWorker

  idempotent!

  def perform(current_user_id)
    current_user = User.find(current_user_id)

    csv_data = Members::PermissionsExportService.new(current_user).csv_data
  end
end
