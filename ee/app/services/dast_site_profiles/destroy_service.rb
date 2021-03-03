# frozen_string_literal: true

module DastSiteProfiles
  class DestroyService < BaseService
    include Gitlab::Allowable

    def execute(id:)
      return unauthorized unless can_delete_site_profile?

      dast_site_profile = find_dast_site_profile(id)
      return ServiceResponse.error(message: "Site profile not found for given parameters") unless dast_site_profile
      return ServiceResponse.error(message: "Cannot delete #{dast_site_profile.name} referenced in security policy") if referenced_in_security_policy?(dast_site_profile)

      if dast_site_profile.destroy
        ServiceResponse.success(payload: dast_site_profile)
      else
        ServiceResponse.error(message: 'Site profile failed to delete')
      end
    end

    private

    def unauthorized
      ::ServiceResponse.error(message: _('You are not authorized to delete this site profile'), http_status: 403)
    end

    def referenced_in_security_policy?(profile)
      profile.referenced_in_security_policies.present?
    end

    def can_delete_site_profile?
      can?(current_user, :create_on_demand_dast_scan, project)
    end

    def find_dast_site_profile(id)
      project.dast_site_profiles.id_in(id).first
    end
  end
end
