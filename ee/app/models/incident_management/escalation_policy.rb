# frozen_string_literal: true

module IncidentManagement
  class EscalationPolicy < ApplicationRecord
    self.table_name = 'incident_management_escalation_policies'

    belongs_to :project
    has_many :rules, class_name: 'EscalationRule', inverse_of: :policy

    validates :name, presence: true, uniqueness: { scope: [:project_id] }, length: { maximum: 72 }
    validates :description, length: { maximum: 160 }
  end
end
