# frozen_string_literal: true

module Security
  module SecurityOrchestrationPolicies
    class RuleScheduleService < BaseContainerService
      def execute(schedule)
        schedule.schedule_next_run!
        actions_for(schedule)
          .each { |action| process_action(action) }
      end

      private

      def actions_for(schedule)
        policy = schedule.policy
        return [] if policy.blank?

        policy[:actions]
      end

      def process_action(action)
        case action[:scan]
        when 'dast' then schedule_dast_on_demand_scan(action)
        end
      end

      def schedule_dast_on_demand_scan(action)
        dast_site_profile = find_dast_site_profile(container, action[:site_profile])
        dast_scanner_profile = find_dast_scanner_profile(container, action[:scanner_profile])

        ::DastOnDemandScans::CreateService.new(
          container: container,
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
