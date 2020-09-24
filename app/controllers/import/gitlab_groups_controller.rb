# frozen_string_literal: true

class Import::GitlabGroupsController < ApplicationController
  include WorkhorseImportExportUpload

  before_action :ensure_group_import_enabled
  before_action :import_rate_limit, only: %i[create]

  def create
    unless file_is_valid?(group_params[:file])
      return redirect_back_or_default(options: { alert: s_('GroupImport|Unable to process group import file') })
    end

    group_data = group_params.except(:file).merge(
      visibility_level: closest_allowed_visibility_level,
      import_export_upload: ImportExportUpload.new(import_file: group_params[:file])
    )

    group = ::Groups::CreateService.new(current_user, group_data).execute

    if group.persisted?
      if Groups::ImportExport::ImportService.new(group: group, user: current_user).async_execute
        redirect_to(
          group_path(group),
          notice: s_("GroupImport|Group '%{group_name}' is being imported.") % { group_name: group.name }
        )
      else
        redirect_to group_path(group), alert: _("Group import could not be scheduled")
      end
    else
      redirect_back_or_default(
        options: { alert: s_("GroupImport|Group could not be imported: %{errors}") % { errors: group.errors.full_messages.to_sentence } }
      )
    end
  end

  private

  def group_params
    params.permit(:path, :name, :parent_id, :file)
  end

  def closest_allowed_visibility_level
    if group_params[:parent_id].present?
      parent_group = Group.find(group_params[:parent_id])

      Gitlab::VisibilityLevel.closest_allowed_level(parent_group.visibility_level)
    else
      Gitlab::VisibilityLevel::PRIVATE
    end
  end

  def ensure_group_import_enabled
    render_404 unless Feature.enabled?(:group_import_export, @group, default_enabled: true)
  end

  def import_rate_limit
    if Gitlab::ApplicationRateLimiter.throttled?(:group_import, scope: current_user)
      Gitlab::ApplicationRateLimiter.log_request(request, :group_import_request_limit, current_user)

      flash[:alert] = _('This endpoint has been requested too many times. Try again later.')
      redirect_to new_group_path
    end
  end
end
