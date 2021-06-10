# frozen_string_literal: true

module GitlabSubscriptions
  module UpcomingReconciliationHelper
    include Gitlab::Utils::StrongMemoize

    COOKIE_KEY_PREFIX = 'hide_upcoming_reconciliation_alert'

    def upcoming_reconciliation_hash(namespace = nil)
      return {} unless display_upcoming_reconciliation_alert?(namespace)

      reconciliation = upcoming_reconciliation(namespace&.id)
      {
        reconciliation_date: reconciliation.next_reconciliation_date.to_s,
        cookie_key: cookie_key(reconciliation, namespace&.id)
      }
    end

    def display_upcoming_reconciliation_alert?(namespace = nil)
      return false unless has_permissions?(namespace)

      reconciliation = upcoming_reconciliation(namespace&.id)
      return false unless reconciliation&.display_alert?

      return false if alert_dismissed?(reconciliation, namespace&.id)

      true
    end

    private

    def upcoming_reconciliation(namespace_id)
      strong_memoize(:upcoming_reconciliation) do
        UpcomingReconciliation.next(namespace_id)
      end
    end

    def alert_dismissed?(reconciliation, namespace_id)
      key = cookie_key(reconciliation, namespace_id)

      cookies[key] == 'true'
    end

    def cookie_key(reconciliation, namespace_id)
      if saas?
        "#{COOKIE_KEY_PREFIX}_#{current_user.id}_#{namespace_id}_#{reconciliation.next_reconciliation_date}"
      else
        "#{COOKIE_KEY_PREFIX}_#{current_user.id}_#{reconciliation.next_reconciliation_date}"
      end
    end

    def has_permissions?(namespace)
      if saas?
        user_can_admin?(namespace)
      else
        user_is_admin?
      end
    end

    def user_is_admin?
      current_user.can_admin_all_resources?
    end

    def user_can_admin?(namespace)
      Ability.allowed?(current_user, :admin_namespace, namespace)
    end

    def saas?
      ::Gitlab.com?
    end
  end
end
