# frozen_string_literal: true

module IncidentManagement
  class OncallShift < ApplicationRecord
    self.table_name = 'incident_management_oncall_shifts'

    belongs_to :rotation, class_name: 'OncallRotation', inverse_of: :shifts, foreign_key: :rotation_id
    belongs_to :participant, class_name: 'OncallParticipant', inverse_of: :shifts, foreign_key: :participant_id

    validates :starts_at, presence: true
    validates :ends_at, presence: true
  end
end
