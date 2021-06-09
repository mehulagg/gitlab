# frozen_string_literal: true

module GitlabSubscriptions
  class UpcomingReconciliationLib
    COOKIE_KEY_PREFIX = 'hide_upcoming_reconciliation_alert'

    class << self
      def cookie_key(reconciliation, current_user, namespace_id)
        if saas?
          "#{COOKIE_KEY_PREFIX}_#{current_user.id}_#{namespace_id}_#{reconciliation.next_reconciliation_date}"
        else
          "#{COOKIE_KEY_PREFIX}_#{current_user.id}_#{reconciliation.next_reconciliation_date}"
        end
      end

      def has_permissions?(current_user, namespace)
        if saas?
          user_can_admin?(current_user, namespace)
        else
          user_is_admin?(current_user)
        end
      end

      private

      def user_is_admin?(current_user)
        current_user.can_admin_all_resources?
      end

      def user_can_admin?(current_user, namespace)
        Ability.allowed?(current_user, :admin_namespace, namespace)
      end

      def saas?
        ::Gitlab.com?
      end
    end
  end
end
