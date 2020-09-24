# frozen_string_literal: true

module DastSiteProfiles
  class CreateService < BaseService
    def execute(name:, target_url:)
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      ActiveRecord::Base.transaction do
        service = DastSites::FindOrCreateService.new(project, current_user)
        dast_site = service.execute!(url: target_url)

        dast_site_profile = DastSiteProfile.create!(project: project, dast_site: dast_site, name: name)
        ServiceResponse.success(payload: dast_site_profile)
      end

    rescue ActiveRecord::RecordInvalid => err
      ServiceResponse.error(message: err.record.errors.full_messages)
    end

    private

    def allowed?
      Ability.allowed?(current_user, :create_on_demand_dast_scan, project)
    end
  end
end
