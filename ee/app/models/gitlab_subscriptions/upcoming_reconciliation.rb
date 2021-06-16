# frozen_string_literal: true

module GitlabSubscriptions
  class UpcomingReconciliation < ApplicationRecord
    belongs_to :namespace, inverse_of: :upcoming_reconciliation, optional: true

    # Validate presence of namespace_id if this is running on a GitLab instance
    # that has paid namespaces.
    validates :namespace, uniqueness: true, presence: { if: proc { ::Gitlab::CurrentSettings.should_check_namespace_plan? } }

    def self.next(namespace_id = nil)
      if ::Gitlab::CurrentSettings.should_check_namespace_plan?
        return unless namespace_id

        self.find_by(namespace_id: namespace_id)
      else
        self.find_by(namespace_id: nil)
      end
    end

    def display_alert?
      next_reconciliation_date >= Date.current && display_alert_from <= Date.current
    end
  end
end
