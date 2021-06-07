# frozen_string_literal: true

module IncidentManagement
  class IssuableEscalationStatus < ApplicationRecord
    self.table_name = 'incident_management_issuable_escalation_statuses'

    belongs_to :issue

    enum status: AlertManagement::Alert::STATUSES

    validates :issue, presence: true, uniqueness: true
    validates :status, presence: true
  end
end
