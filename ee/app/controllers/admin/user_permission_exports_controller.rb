# frozen_string_literal: true

class Admin::UserPermissionExportsController < Admin::ApplicationController
  feature_category :users

  def create
    response = MemberPermissions::ExportService.new(current_user).execute

    respond_to do |format|
      format.csv do
        if response.success?
          no_cache_headers
          stream_headers

          headers['Content-Type'] = 'text/csv; charset=utf-8; header=present'
          headers['Content-Disposition'] = "attachment; filename=\"#{csv_filename}\""

          self.response_body = response.payload
        else
          flash[:alert] = _('Failed to generate report, please try again after sometime')

          redirect_to admin_users_path
        end
      end
    end
  end

  private

  def csv_filename
    "user-permissions-export-#{Time.current.to_i}.csv"
  end
end
