# frozen_string_literal: true

module IncidentManagement
  class IssuableEscalation < ApplicationRecord
    self.table_name = 'incident_management_issuable_escalations'

    belongs_to :issue
    belongs_to :policy, class_name: 'EscalationPolicy', inverse_of: 'issuable_escalations', foreign_key: 'policy_id'

    validates :issue, presence: true, uniqueness: true
    validates :policy, presence: true
  end
end
