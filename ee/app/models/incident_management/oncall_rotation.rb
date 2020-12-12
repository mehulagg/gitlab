# frozen_string_literal: true

module IncidentManagement
  class OncallRotation < ApplicationRecord
    self.table_name = 'incident_management_oncall_rotations'

    enum length_unit: {
      hours: 0,
      days:  1,
      weeks: 2
    }

    NAME_LENGTH = 200

    belongs_to :schedule, class_name: 'OncallSchedule', inverse_of: 'rotations', foreign_key: 'oncall_schedule_id'
    has_many :participants, class_name: 'OncallParticipant', inverse_of: :rotation
    has_many :users, through: :participants

    validates :name, presence: true, uniqueness: { scope: :oncall_schedule_id }, length: { maximum: NAME_LENGTH }
    validates :starts_at, presence: true
    validates :length, presence: true
    validates :length_unit, presence: true

    delegate :project, to: :schedule
  end
end
