# frozen_string_literal: true
class Groups::Security::MergeCommitReportsController < Groups::ApplicationController
  include Groups::SecurityFeaturesHelper

  before_action :authorize_compliance_dashboard!

  def index
    csv_data = MergeCommits::ExportCsvService.new(current_user, group).csv_data

    respond_to do |format|
      format.csv do
        send_data(
          csv_data,
          type: 'text/csv; charset=utf-8; header=present',
          filename: merge_commits_csv_filename
        )
      end
    end
  end

  private

  def merge_commits_csv_filename
    "#{group.id}-merge-commits-#{Time.current.to_i}.csv"
  end
end
