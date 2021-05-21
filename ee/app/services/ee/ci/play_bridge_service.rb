# frozen_string_literal: true

module EE
  module Ci
    module PlayBridgeService
      extend ::Gitlab::Utils::Override

      private

      override :check_access!
      def check_access!(bridge)
        super

        if current_user && !current_user.has_required_credit_card_to_run_pipelines?(project)
          ::Gitlab::AppLogger.info(
            message: 'Credit card required to be on file in order to play a job',
            project_path: project.full_path,
            user_id: current_user.id,
            plan: project.root_namespace.actual_plan_name
          )

          raise ::Gitlab::Access::AccessDeniedError, 'Credit card required to be on file in order to play a job'
        end
      end
    end
  end
end
