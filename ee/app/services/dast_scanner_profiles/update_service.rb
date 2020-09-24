# frozen_string_literal: true

module DastScannerProfiles
  class UpdateService < BaseService
    include Gitlab::Allowable

    def execute(id:, profile_name:, target_timeout:, spider_timeout:, active_scan:, ajax_spider:, show_debug_messages:)
      return unauthorized unless can_update_scanner_profile?

      dast_scanner_profile = find_dast_scanner_profile(id)
      return ServiceResponse.error(message: "Scanner profile not found for given parameters") unless dast_scanner_profile

      if dast_scanner_profile.update(name: profile_name, target_timeout: target_timeout, spider_timeout: spider_timeout, active_scan: active_scan, ajax_spider: ajax_spider, show_debug_messages: show_debug_messages)
        ServiceResponse.success(payload: dast_scanner_profile)
      else
        ServiceResponse.error(message: dast_scanner_profile.errors.full_messages)
      end
    end

    private

    def unauthorized
      ::ServiceResponse.error(message: _('You are not authorized to update this scanner profile'), http_status: 403)
    end

    def can_update_scanner_profile?
      can?(current_user, :create_on_demand_dast_scan, project)
    end

    def find_dast_scanner_profile(id)
      project.dast_scanner_profiles.id_in(id).first
    end
  end
end
