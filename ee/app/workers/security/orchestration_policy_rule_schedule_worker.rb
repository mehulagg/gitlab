# frozen_string_literal: true
module Security
  class OrchestrationPolicyRuleScheduleWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    # rubocop:disable Scalability/CronWorkerContext
    # This worker does not perform work scoped to a context
    include CronjobQueue
    # rubocop:enable Scalability/CronWorkerContext

    feature_category :security_orchestration
    worker_resource_boundary :cpu

    def perform
      Security::OrchestrationPolicyRuleSchedule.runnable_schedules.find_in_batches do |schedules|
        schedules.each do |schedule|
          with_context(project: schedule.project, user: schedule.owner) do
            Security::OrchestrationPolicies::RuleScheduleService.new(schedule.project, schedule.owner).execute(schedule)
          end
        end
      end
    end
  end
end
