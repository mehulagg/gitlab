# frozen_string_literal: true

module Security
  module SecurityOrchestrationPolicies
    class RuleScheduleService < ::BaseService
      def execute(schedule)
        schedule.schedule_next_run!
        actions_for(schedule)
          .each { |action| process_action(action) }
      end

      def actions_for(schedule)
        return [] if schedule.policy.blank?

        schedule.policy[:actions]
      end

      def process_action(action)
        case action[:scan]
        when 'dast' then schedule_dast_on_demand_scan(action)
        end
      end

      def schedule_dast_on_demand_scan(action)
        dast_site_profile = find_dast_site_profile(project, action['site_profile'])
        dast_scanner_profile = find_dast_scanner_profile(project, action['scan_profile'])

        ::DastOnDemandScans::CreateService.new(
          container: project,
          current_user: current_user,
          params: {
            dast_site_profile: dast_site_profile,
            dast_scanner_profile: dast_scanner_profile
          }
        ).execute
      end

      def find_dast_site_profile(project, dast_site_profile)
        DastSiteProfilesFinder.new(project_id: project.id, name: dast_site_profile).execute.first
      end

      def find_dast_scanner_profile(project, dast_scanner_profile)
        return unless dast_scanner_profile

        DastScannerProfilesFinder.new(project_ids: [project.id], name: dast_scanner_profile).execute.first
      end
    end
  end
end
