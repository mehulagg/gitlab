# frozen_string_literal: true

module Dast
  class ProfileScheduleWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    # rubocop:disable Scalability/CronWorkerContext
    # This worker does not perform work scoped to a context
    include CronjobQueue
    # rubocop:enable Scalability/CronWorkerContext

    # What is this?
    # feature_category :security_orchestration

    def perform
      Dast::ProfileSchedule.with_profile_project.with_owner.runnable_schedules.find_in_batches do |schedules|
        schedules.each do |schedule|
          project = schedule.project
          profile = schedule.profile

          # QUES-AD: What is with_context?
          with_context(project: project, user: schedule.owner) do
            schedule.schedule_next_run!
            
            ::DastOnDemandScans::CreateService.new(
              container: project,
              current_user: schedule.owner,
              params: {
                dast_site_profile: profile.dast_site_profile,
                dast_scanner_profile: profile.dast_scanner_profile
              }
            ).execute
          end
        end
      end
    end
  end
end
