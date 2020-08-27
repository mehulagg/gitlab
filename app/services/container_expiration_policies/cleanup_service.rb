# frozen_string_literal: true

module ContainerExpirationPolicies
  class CleanupService < BaseContainerService
    alias_method :repository, :container

    def execute
      return error('no repository') unless repository

      log_cleanup_status(:starting)
      repository.start_expiration_policy!

      result = Projects::ContainerRepository::CleanupTagsService
        .new(project, nil, policy_params.merge('container_expiration_policy' => true))
        .execute(repository)
      log_cleanup_status(:service_execution_done, service_result_status: result[:status], service_result_message: result[:message])

      if result[:status] == :success
        repository.cleanup_unscheduled!
        repository.reset_expiration_policy_started_at!
        log_cleanup_status(:finished)
        success(cleanup_status: :finished)
      else
        repository.cleanup_unfinished!
        log_cleanup_status(:unfinished)
        success(cleanup_status: :unfinished)
      end
    end

    private

    def log_cleanup_status(status, extra_structure = {})
      base_structure = {
        service_class: self.class.to_s,
        container_repository_id: repository.id,
        cleanup_status: status
      }
      log_info(base_structure.merge(extra_structure))
    end

    def policy_params
      return {} unless policy

      policy.policy_params
    end

    def policy
      project.container_expiration_policy
    end

    def project
      repository&.project
    end
  end
end
