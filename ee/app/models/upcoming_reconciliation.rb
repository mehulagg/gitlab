# frozen_string_literal: true

class UpcomingReconciliation < ApplicationRecord
  belongs_to :namespace, inverse_of: :upcoming_reconciliation

  validates :namespace, presence: { if: Proc.new { ::Gitlab.com? } }

  def display_alert?
    next_reconciliation_date >= Date.current && display_alert_from <= Time.current
  end
end
