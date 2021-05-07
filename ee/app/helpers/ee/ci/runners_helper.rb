# frozen_string_literal: true
module EE
  module Ci
    module RunnersHelper
      include ::Gitlab::Utils::StrongMemoize

      BUY_PIPELINE_MINUTES_NOTIFICATION_DOT = 'buy_pipeline_minutes_notification_dot'

      def show_buy_pipeline_minutes?(project, namespace)
        return false unless ::Gitlab.dev_env_or_com?

        show_out_of_pipeline_minutes_notification?(project, namespace)
      end

      def show_pipeline_minutes_notification_dot?(project, namespace)
        return false unless ::Gitlab.dev_env_or_com?
        return false if notification_dot_acknowledged?

        show_out_of_pipeline_minutes_notification?(project, namespace)
      end

      def show_buy_pipeline_with_subtext?(project, namespace)
        return false unless ::Gitlab.dev_env_or_com?
        return false unless notification_dot_acknowledged?

        show_out_of_pipeline_minutes_notification?(project, namespace)
      end

      def root_ancestor_namespace(project, namespace)
        (project || namespace).root_ancestor
      end

      private

      def notification_dot_acknowledged?
        strong_memoize(:notification_dot_acknowledged) do
          user_dismissed?(BUY_PIPELINE_MINUTES_NOTIFICATION_DOT)
        end
      end

      def show_out_of_pipeline_minutes_notification?(project, namespace)
        strong_memoize(:show_out_of_pipeline_minutes_notification) do
          next unless project&.persisted? || namespace&.persisted?

          ::Ci::Minutes::Notification.new(project, namespace).show?(current_user)
        end
      end
    end
  end
end
