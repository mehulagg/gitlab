# frozen_string_literal: true

module GitlabSubscriptions
  class UpcomingReconciliation < ApplicationRecord
    belongs_to :namespace, inverse_of: :upcoming_reconciliation, optional: true

    validates :namespace, uniqueness: true, presence: { if: proc { ::Gitlab.com? } }

    def self.for_self_managed
      self.find_by(namespace_id: nil)
    end

    def display_alert?
      next_reconciliation_date >= Date.current && display_alert_from <= Date.current
    end
  end
end
