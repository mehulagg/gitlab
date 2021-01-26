# frozen_string_literal: true
module Security
  class OrchestrationPolicyRuleScheduleWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include CronjobQueue

    feature_category :vulnerability_management
    worker_resource_boundary :cpu

    def perform
      Security::OrchestrationPolicyRuleSchedule.runnable_schedules.find_in_batches do |schedules|
        schedules.each do |schedule|
          schedule.security_orchestration_policy_projects.each do |project|
            with_context(project: project, user: schedule.owner) do
              Security::OrchestrationPolicies::RuleScheduleService.new(project, schedule.owner).execute(schedule)
            end
          end
        end
      end
    end
  end
end
