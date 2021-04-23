# frozen_string_literal: true

module DastSiteProfiles
  class CreateService < BaseService
    class Rollback < StandardError
      attr_reader :errors

      def initialize(errors)
        @errors = errors
      end
    end

    attr_reader :dast_site_profile

    def execute(name:, target_url:, **params)
      return ServiceResponse.error(message: _('Insufficient permissions')) unless allowed?

      ActiveRecord::Base.transaction do
        dast_site = DastSites::FindOrCreateService.new(project, current_user).execute!(url: target_url)
        params.merge!(project: project, dast_site: dast_site, name: name).compact!

        @dast_site_profile = DastSiteProfile.create!(params.except(:request_headers, :auth_password))
        create_secret_variable!(Dast::SiteProfileSecretVariable::PASSWORD, params[:auth_password])
        create_secret_variable!(Dast::SiteProfileSecretVariable::REQUEST_HEADERS, params[:request_headers])

        ServiceResponse.success(payload: dast_site_profile)
      end
    rescue Rollback => e
      ServiceResponse.error(message: e.errors)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResponse.error(message: e.record.errors.full_messages)
    end

    private

    def allowed?
      Ability.allowed?(current_user, :create_on_demand_dast_scan, project)
    end

    def create_secret_variable!(key, value)
      return ServiceResponse.success unless value

      response = Dast::SiteProfileSecretVariables::CreateOrUpdateService.new(
        container: project,
        current_user: current_user,
        params: { dast_site_profile: dast_site_profile, key: key, raw_value: value }
      ).execute

      raise Rollback, response.errors if response.error?

      response
    end
  end
end
