# frozen_string_literal: true

module DastSiteProfiles
  class CreateService < BaseService
    def execute(name:, target_url:)
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      ActiveRecord::Base.transaction do
        service = DastSites::FindOrCreateService.new(project, current_user)
        dast_site = service.execute!(url: target_url)

        dast_site_profile = DastSiteProfile.create!(project: project, dast_site: dast_site, name: name)

        environment_scope = "dast_site_profile/#{dast_site_profile.id}"

        Environment.create!(
          project: project,
          name: environment_scope
        )

        Ci::Variable.create!(
          project_id: 22,
          key: 'DAST_USERNAME_BASE64',
          value: SecureRandom.base64,
          masked: true,
          environment_scope: environment_scope
        )

        Ci::Variable.create!(
          project_id: 22,
          key: 'DAST_PASSWORD_BASE64',
          value: SecureRandom.base64,
          masked: true,
          environment_scope: environment_scope
        )

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
