# frozen_string_literal: true

class ContainerExpirationPolicyWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include CronjobQueue

  feature_category :container_registry

  InvalidPolicyError = Class.new(StandardError)

  def perform
    throttling_enabled? ? perform_throttled : perform_unthrottled
  end

  private

  def perform_unthrottled
    runnable_policies.each do |container_expiration_policy|
      with_context(project: container_expiration_policy.project,
                   user: container_expiration_policy.project.owner) do |project:, user:|
        ContainerExpirationPolicyService.new(project, user)
                                        .execute(container_expiration_policy)
      end
    end
  end

  def perform_throttled
    policies = runnable_policies
    return unless policies.any?

    ContainerRepository.transaction do
      policies.each(&:schedule_next_run!)

      ContainerRepository.for_project(policies.select(:project_id))
                         .each_batch do |relation|
                           relation.update_all(expiration_policy_cleanup_status: :cleanup_scheduled)
                         end
    end

    ContainerExpirationPolicies::CleanupContainerRepositoryWorker.perform_with_capacity
  end

  def runnable_policies
    valid, invalid = ContainerExpirationPolicy.runnable_schedules
                                              .preloaded
                                              .partition { |policy| policy.valid? }

    invalid.each do |policy|
      policy.disable!
      Gitlab::ErrorTracking.log_exception(
        ::ContainerExpirationPolicyWorker::InvalidPolicyError.new,
        container_expiration_policy_id: policy.id
      )
    end

    ContainerExpirationPolicy.primary_key_in(valid.map(&:project_id))
  end

  def throttling_enabled?
    Feature.enabled?(:container_registry_expiration_policies_throttling)
  end
end
