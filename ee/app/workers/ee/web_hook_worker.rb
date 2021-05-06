# frozen_string_literal: true

module EE
  module WebHookWorker
    extend ActiveSupport::Concern

    class_methods do
      extend ::Gitlab::Utils::Override

      private

      override :current_plan_limits
      def current_plan_limits(hook)
        case hook
        when GroupHook
          hook.group.actual_limits
        when ProjectHook
          hook.project.actual_limits
        when ServiceHook
          hook.service.project.actual_limits
        else
          super
        end
      end
    end
  end
end
