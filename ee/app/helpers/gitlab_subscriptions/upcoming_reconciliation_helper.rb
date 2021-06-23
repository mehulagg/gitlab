# frozen_string_literal: true

module GitlabSubscriptions
  module UpcomingReconciliationHelper
    def upcoming_reconciliation_hash(namespace = nil)
      return {} unless display_upcoming_reconciliation_alert?(namespace)

      entity = reconciliation_entity(namespace)

      {
        reconciliation_date: entity.next_reconciliation_date.to_s,
        cookie_key: entity.cookie_key,
        uses_namespace_plan: Gitlab::CurrentSettings.should_check_namespace_plan?
      }
    end

    def display_upcoming_reconciliation_alert?(namespace = nil)
      entity = reconciliation_entity(namespace)

      return false unless entity.has_permissions?
      return false unless entity.display_alert?
      return false if cookies[entity.cookie_key] == 'true'

      true
    end

    def reconciliation_entity(namespace)
      @reconciliation_entity ||= GitlabSubscriptions::UpcomingReconciliationEntity.new(current_user: current_user, namespace: namespace)
    end
  end
end
