# frozen_string_literal: true

module DastSiteProfiles
  class UpdateService < BaseService
    attr_reader :dast_site_profile

    def execute(id:, **params)
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      @dast_site_profile = find_dast_site_profile!(id)

      return ServiceResponse.error(message: "Cannot modify #{dast_site_profile.name} referenced in security policy") if referenced_in_security_policy?

      ActiveRecord::Base.transaction do
        if target_url = params.delete(:target_url)
          params[:dast_site] = DastSites::FindOrCreateService.new(project, current_user).execute!(url: target_url)
        end

        response = handle_secret_variable(params, :request_headers, Dast::SiteProfileSecretVariable::REQUEST_HEADERS)
        break response if response.error?

        response = handle_secret_variable(params, :auth_password, Dast::SiteProfileSecretVariable::PASSWORD)
        break response if response.error?

        params.compact!

        dast_site_profile.update!(params)

        ServiceResponse.success(payload: dast_site_profile)
      end
    rescue ActiveRecord::RecordNotFound => err
      ServiceResponse.error(message: "#{err.model} not found")
    rescue ActiveRecord::RecordInvalid => err
      ServiceResponse.error(message: err.record.errors.full_messages)
    end

    private

    def allowed?
      Ability.allowed?(current_user, :create_on_demand_dast_scan, project)
    end

    def referenced_in_security_policy?
      dast_site_profile.referenced_in_security_policies.present?
    end

    def handle_secret_variable(params, arg, key)
      return ServiceResponse.success unless params.has_key?(arg)

      manage_secret_variable(key, params[arg]).tap { params.delete(arg) }
    end

    def manage_secret_variable(key, value)
      return delete_secret_variable(key) unless value

      response = Dast::SiteProfileSecretVariables::CreateOrUpdateService.new(
        container: project,
        current_user: current_user,
        params: { dast_site_profile: dast_site_profile, key: key, raw_value: value }
      ).execute

      return ServiceResponse.error(payload: dast_site_profile, message: response.errors) if response.error?

      response
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def find_dast_site_profile!(id)
      DastSiteProfilesFinder.new(project_id: project.id, id: id).execute.first!
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # rubocop: disable CodeReuse/ActiveRecord
    def delete_secret_variable(key)
      variable = dast_site_profile.secret_variables.find_by(key: key)

      return ServiceResponse.success unless variable

      Dast::SiteProfileSecretVariables::DestroyService.new(
        container: project,
        current_user: current_user,
        params: { dast_site_profile_secret_variable: variable }
      ).execute
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
