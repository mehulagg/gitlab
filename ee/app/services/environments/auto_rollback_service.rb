# frozen_string_literal: true

module Environments
  class AutoRollbackService < ::BaseService
    MAXIMUM_ROLLBACK_RANGE = 20

    def execute(environment)
      result = validate

      return result unless result[:status] == :success

      deployment = find_rollback_target(environment)

      return error('No rollbackable target is found') unless deployment

      if rollback_to(deployment)
        success(deployment: deployment)
      else
        error("Failed to rollback to the deployment #{deployment.id}")
      end
    end

    private

    def validate(environment)
      unless environment.project.auto_rollback_enabled?
        return error(_('Auto Rollback is not enabled on the project'))
      end

      unless environment.project.feature_available?(:auto_rollback)
        return error(_('The license for Auto Rollback is required to use this feature.'))
      end

      unless environment.has_running_deployments?
        return error(_('There are running deployments on the environment. Please retry later.'))
      end

      success
    end

    def find_rollback_target(environment)
      deployments = environment.all_deployments.order(id: :desc).limit(MAXIMUM_ROLLBACK_RANGE)
      # TODO:
    end

    def rollback_to(deployment)
      Ci::Build.retry(deployment.deployable, deployment.deployable.user)
    end
  end
end
