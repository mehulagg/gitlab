# frozen_string_literal: true

module IncidentManagement
  class OncallRotation < ApplicationRecord
    enum length_unit: {
      hours: 0,
      days:  1,
      weeks: 2
    }

    NAME_LENGTH = 200

    belongs_to :oncall_schedule, inverse_of: 'oncall_rotations', foreign_key: 'oncall_schedule_id'
    has_many :oncall_participants, inverse_of: :oncall_rotation
    has_many :participants, through: :oncall_participants
    has_many :oncall_shifts, foreign_key: :oncall_rotation_id

    validates :name, presence: true, uniqueness: { scope: :oncall_schedule_id }, length: { maximum: NAME_LENGTH }
    validates :starts_at, presence: true
    validates :length, presence: true
    validates :length_unit, presence: true

    delegate :project, to: :oncall_schedule
  end
end
