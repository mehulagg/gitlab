# frozen_string_literal: true

class Admin::UserPermissionsController < Admin::ApplicationController
  def export
    MemberPermissionExport::CreateService.new(current_user).execute
  end
end
