# frozen_string_literal: true

module AppSec
  module Dast
    module SiteProfiles
      class DestroyService < BaseService
        include Gitlab::Allowable

        def execute(id:)
          return unauthorized unless can_delete_site_profile?

          dast_site_profile = find_dast_site_profile(id)
          return ServiceResponse.error(message: _('Site profile not found for given parameters')) unless dast_site_profile
          return ServiceResponse.error(message: _('Cannot delete %{profile_name} referenced in security policy') % { profile_name: dast_site_profile.name }) if referenced_in_security_policy?(dast_site_profile)

          if dast_site_profile.destroy
            create_audit_event(dast_site_profile)

            ServiceResponse.success(payload: dast_site_profile)
          else
            ServiceResponse.error(message: _('Site profile failed to delete'))
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

        def create_audit_event(profile)
          ::Gitlab::Audit::Auditor.audit(
            name: 'dast_site_profile_destroy',
            author: current_user,
            scope: project,
            target: profile,
            message: 'Removed DAST site profile'
          )
        end
      end
    end
  end
end
