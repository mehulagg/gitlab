# frozen_string_literal: true

module IncidentManagement
  class OncallRotation < ApplicationRecord
    self.table_name = 'incident_management_oncall_rotations'

    enum rotation_length_unit: {
        hours: 0,
        days:  1,
        weeks: 2
    }

    NAME_LENGTH = 200

    belongs_to :oncall_schedule, inverse_of: 'oncall_rotations', foreign_key: 'oncall_schedule_id'
    has_many :oncall_participants, inverse_of: :oncall_rotation
    has_many :participants, through: :oncall_participants

    validates :name, presence: true, uniqueness: { scope: :oncall_schedule }, length: { maximum: NAME_LENGTH }
    validates :starts_at, presence: true
    validates :rotation_length, presence: true
    validates :rotation_length_unit, presence: true

    delegate :project, to: :oncall_schedule
  end
end
