# frozen_string_literal: true

module IncidentManagement
  class OncallParticipant < ApplicationRecord
    self.table_name = 'incident_management_oncall_participants'

    belongs_to :oncall_rotation, foreign_key: :oncall_rotation_id
    belongs_to :participant, class_name: 'User', foreign_key: :user_id

    validates :oncall_rotation, presence: true
    validates :participant, presence: true, uniqueness: { scope: :oncall_rotation_id }
  end
end
