# frozen_string_literal: true

module GitlabSubscriptions
  module UpcomingReconciliationHelper
    include Gitlab::Utils::StrongMemoize

    COOKIE_KEY_PREFIX = 'hide_upcoming_reconciliation_alert'

    def upcoming_reconciliation_hash(namespace = nil)
      return {} unless display_upcoming_reconciliation_alert?(namespace)

      klass = GitlabSubscriptions::UpcomingReconciliationLib

      reconciliation = upcoming_reconciliation(namespace&.id)
      {
        reconciliation_date: reconciliation.next_reconciliation_date.to_s,
        cookie_key: klass.cookie_key(reconciliation, current_user, namespace&.id)
      }
    end

    def display_upcoming_reconciliation_alert?(namespace = nil)
      klass = GitlabSubscriptions::UpcomingReconciliationLib
      return false unless klass.has_permissions?(current_user, namespace)

      reconciliation = upcoming_reconciliation(namespace&.id)
      return false unless reconciliation&.display_alert?

      key = klass.cookie_key(reconciliation, current_user, namespace&.id)
      return false if cookies[key] == 'true'

      true
    end

    def upcoming_reconciliation(namespace_id)
      strong_memoize(:upcoming_reconciliation) do
        UpcomingReconciliation.next(namespace_id)
      end
    end
  end
end
