# frozen_string_literal: true

module GitlabSubscriptions
  module UpcomingReconciliationHelper
    include Gitlab::Utils::StrongMemoize

    def upcoming_reconciliation_hash(group = nil)
      {
        display_alert: display_upcoming_reconciliation_alert?(group),
        reconciliation_date: upcoming_reconciliation(group&.id)&.next_reconciliation_date.to_s
      }
    end

    private

    def display_upcoming_reconciliation_alert?(group)
      return false unless has_permissions?(group)

      reconciliation = upcoming_reconciliation(group&.id)
      return false unless reconciliation&.display_alert?

      return false if alert_dismissed?(reconciliation, group)

      true
    end

    def upcoming_reconciliation(group_id)
      strong_memoize(:upcoming_reconciliation) do
        if saas?
          UpcomingReconciliation.for_saas(group_id)
        else
          UpcomingReconciliation.for_self_managed
        end
      end
    end

    def alert_dismissed?(reconciliation, group)
      prefix = "hide_upcoming_reconciliation_alert"
      key =
        if saas?
          "#{prefix}_#{current_user.id}_#{group.id}_#{reconciliation.next_reconciliation_date}"
        else
          "#{prefix}_#{current_user.id}_#{reconciliation.next_reconciliation_date}"
        end

      cookies[key] == 'true'
    end

    def has_permissions?(group)
      if saas?
        user_is_owner?(group)
      else
        user_is_admin?
      end
    end

    def user_is_admin?
      current_user.can_admin_all_resources?
    end

    def user_is_owner?(group)
      can?(current_user, :admin_group, group)
    end

    def saas?
      ::Gitlab.com?
    end
  end
end
