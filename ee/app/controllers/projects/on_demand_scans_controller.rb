# frozen_string_literal: true

module Projects
  class OnDemandScansController < Projects::ApplicationController
    include SecurityAndCompliancePermissions

    before_action :authorize_read_on_demand_scans!, only: :index
    before_action :authorize_create_on_demand_dast_scan!, only: [:new, :edit]

    feature_category :dynamic_application_security_testing

    def index
    end

    def new
    end

    def edit
      dast_profile = Dast::ProfilesFinder.new(project_id: @project.id, id: params[:id]).execute.first! # rubocop: disable CodeReuse/ActiveRecord

      @dast_profile = {
        id: dast_profile.to_global_id.to_s,
        name: dast_profile.name,
        description: dast_profile.description,
        branch: { name: dast_profile.branch_name },
        site_profile_id: DastSiteProfile.new(id: dast_profile.dast_site_profile_id).to_global_id.to_s,
        scanner_profile_id: DastScannerProfile.new(id: dast_profile.dast_scanner_profile_id).to_global_id.to_s
      }
    end
  end
end
