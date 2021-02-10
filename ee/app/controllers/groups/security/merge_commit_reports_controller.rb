# frozen_string_literal: true
class Groups::Security::MergeCommitReportsController < Groups::ApplicationController
  include Groups::SecurityFeaturesHelper

  before_action :authorize_compliance_dashboard!

  feature_category :compliance_management

  def index
    response = MergeCommits::ExportCsvService.new(current_user, group, filter_params).csv_data

    respond_to do |format|
      format.csv do
        if response&.success?
          send_data(
            response.payload,
            type: 'text/csv; charset=utf-8; header=present',
            filename: merge_commits_csv_filename
          )
        else
          flash[:alert] = _('An error occurred while trying to generate the report. Please try again later.')

          redirect_to group_security_compliance_dashboard_path(group)
        end
      end
    end
  end

  private

  def merge_commits_csv_filename
    "#{group.id}-merge-commits-#{Time.current.to_i}.csv"
  end

  def filter_params
    params.permit(:commit_sha)
  end
end
