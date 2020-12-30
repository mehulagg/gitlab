# frozen_string_literal: true

class Admin::UserPermissionsController < Admin::ApplicationController
  def export
    csv_data = Members::PermissionsExportService.new(current_user).csv_data

    respond_to do |format|
      format.csv do
        no_cache_headers
        stream_headers

        headers['Content-Type'] = 'text/csv; charset=utf-8; header=present'
        headers['Content-Disposition'] = "attachment; filename=\"#{csv_filename}\""

        self.response_body = csv_data
      end
    end
  end
end
