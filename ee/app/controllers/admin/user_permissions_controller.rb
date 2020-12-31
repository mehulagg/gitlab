# frozen_string_literal: true

class Admin::UserPermissionsController < Admin::ApplicationController
  def export
    response = MemberPermissionExport::CreateService.new(current_user).execute

    if response.success?
      render json: { message: response.message }
    else
      render json: { errors: response.message }, status: :unprocessable_entity
    end
  end
end
