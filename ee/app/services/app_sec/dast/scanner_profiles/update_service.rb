# frozen_string_literal: true

module AppSec
  module Dast
    module ScannerProfiles
      class UpdateService < BaseService
        include Gitlab::Allowable

        def execute(**args)
          return unauthorized unless can_update_scanner_profile?

          dast_scanner_profile = find_dast_scanner_profile(args[:id])
          return ServiceResponse.error(message: _('Scanner profile not found for given parameters')) unless dast_scanner_profile
          return ServiceResponse.error(message: _('Cannot modify %{profile_name} referenced in security policy') % { profile_name: dast_scanner_profile.name }) if referenced_in_security_policy?(dast_scanner_profile)

          update_args, old_args = construct_update_args(args, dast_scanner_profile)

          if dast_scanner_profile.update(update_args)
            audit_update(dast_scanner_profile, update_args, old_args)

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

        def construct_update_args(args, profile)
          old_args = {
            name: profile.name,
            scan_type: profile.scan_type,
            show_debug_messages: profile.show_debug_messages,
            spider_timeout: profile.spider_timeout,
            target_timeout: profile.target_timeout,
            use_ajax_spider: profile.use_ajax_spider
          }
          update_args = {
            name: args[:profile_name],
            target_timeout: args[:target_timeout],
            spider_timeout: args[:spider_timeout]
          }

          update_args[:scan_type] = args[:scan_type] if args[:scan_type]
          update_args[:use_ajax_spider] = args[:use_ajax_spider] unless args[:use_ajax_spider].nil?
          update_args[:show_debug_messages] = args[:show_debug_messages] unless args[:show_debug_messages].nil?

          [update_args, old_args]
        end

        def audit_update(profile, update_args, old_args)
          update_args.each do |property, new_value|
            old_value = old_args[property]

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
