# frozen_string_literal: true

module Environments
  module CanaryIngress
    class UpdateService < ::BaseService
      def execute(environment)
        result = validate(environment)

        return result unless result[:status] == :success

        Environments::CanaryIngress::PatchWorker.perform_async(environment.id, params)

        success
      end

      private

      def validate(environment)
        unless Feature.enabled?(:canary_ingress_weight_control, environment.project)
          return error(_("Feature flag is not enabled on the environment's project."))
        end

        unless can?(current_user, :update_environment, environment)
          return error(_('You do not have permission to update the environment.'))
        end

        unless environment.project.feature_available?(:deploy_board)
          return error(_('The license for Deploy Board is required to use this feature.'))
        end

        unless params[:weight].is_a?(Integer) && (0..100).cover?(params[:weight])
          return error(_('Canary weight must be specified and valid range (0..100).'))
        end

        if environment.has_running_deployments?
          return error(_('There are running deployments on the environment. Please retry later.'))
        end

        if ::Gitlab::ApplicationRateLimiter.throttled?(:update_environment_canary_ingress, scope: [environment])
          return error(_("This environment's canary ingress has been updated recently. Please retry later."))
        end

        success
      end
    end
  end
end
