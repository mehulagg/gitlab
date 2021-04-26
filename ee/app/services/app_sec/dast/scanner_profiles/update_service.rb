# frozen_string_literal: true

module AppSec
  module Dast
    module ScannerProfiles
      class UpdateService < BaseService
        include Gitlab::Allowable

        def execute(**params)
          return unauthorized unless can_update_scanner_profile?

          dast_scanner_profile = find_dast_scanner_profile(params[:id])
          return ServiceResponse.error(message: _('Scanner profile not found for given parameters')) unless dast_scanner_profile
          return ServiceResponse.error(message: _('Cannot modify %{profile_name} referenced in security policy') % { profile_name: dast_scanner_profile.name }) if referenced_in_security_policy?(dast_scanner_profile)

          old_params = dast_scanner_profile.attributes.symbolize_keys
          update_params = {
            name: params[:profile_name],
            target_timeout: params[:target_timeout],
            spider_timeout: params[:spider_timeout]
          }
          update_params[:scan_type] = params[:scan_type] if params[:scan_type]
          update_params[:use_ajax_spider] = params[:use_ajax_spider] unless params[:use_ajax_spider].nil?
          update_params[:show_debug_messages] = params[:show_debug_messages] unless params[:show_debug_messages].nil?

          if dast_scanner_profile.update(update_params)
            audit_update(dast_scanner_profile, update_params, old_params)

            ServiceResponse.success(payload: dast_scanner_profile)
          else
            ServiceResponse.error(message: dast_scanner_profile.errors.full_messages)
          end
        end

        private

        def unauthorized
          ::ServiceResponse.error(message: _('You are not authorized to update this scanner profile'), http_status: 403)
        end

        def referenced_in_security_policy?(profile)
          profile.referenced_in_security_policies.present?
        end

        def can_update_scanner_profile?
          can?(current_user, :create_on_demand_dast_scan, project)
        end

        def find_dast_scanner_profile(id)
          DastScannerProfilesFinder.new(project_ids: [project.id], ids: [id]).execute.first
        end

        def audit_update(profile, params, old_params)
          params.each do |property, new_value|
            old_value = old_params[property]

            next if old_value == new_value

            AuditEventService.new(current_user, project, {
              change: "DAST scanner profile #{property}",
              from: old_value,
              to: new_value,
              target_id: profile.id,
              target_type: 'DastScannerProfile',
              target_details: profile.name
            }).security_event
          end
        end
      end
    end
  end
end
