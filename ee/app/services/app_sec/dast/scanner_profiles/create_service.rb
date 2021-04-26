# frozen_string_literal: true

module AppSec
  module Dast
    module ScannerProfiles
      class CreateService < BaseService
        def execute(name:, target_timeout:, spider_timeout:, scan_type:, use_ajax_spider:, show_debug_messages:)
          return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

          dast_scanner_profile = DastScannerProfile.create(
            project: project,
            name: name,
            target_timeout: target_timeout,
            spider_timeout: spider_timeout,
            scan_type: scan_type,
            use_ajax_spider: use_ajax_spider,
            show_debug_messages: show_debug_messages
          )

          if dast_scanner_profile.valid?
            audit_creation(dast_scanner_profile)

            ServiceResponse.success(payload: dast_scanner_profile)
          else
            ServiceResponse.error(message: dast_scanner_profile.errors.full_messages)
          end
        end

        private

        def allowed?
          Ability.allowed?(current_user, :create_on_demand_dast_scan, project)
        end

        def audit_creation(profile)
          AuditEventService.new(
            current_user, project, { action: :create }
          ).for_dast_scanner_profile(profile).security_event
        end
      end
    end
  end
end
