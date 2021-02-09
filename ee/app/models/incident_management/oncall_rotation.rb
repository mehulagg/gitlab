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
    has_many :shifts, class_name: 'OncallShift', inverse_of: :rotation, foreign_key: :rotation_id

    validates :name, presence: true, uniqueness: { scope: :oncall_schedule_id }, length: { maximum: NAME_LENGTH }
    validates :starts_at, presence: true
    validates :length, presence: true, numericality: true
    validates :length_unit, presence: true
    validate :valid_ends_at, if: -> { ends_at && starts_at }

    scope :started, -> { where('starts_at < :time AND (ends_at > :time OR ends_at IS NULL)', time: Time.current) }

    delegate :project, to: :schedule

    def shift_duration
      # As length_unit is an enum, input is guaranteed to be appropriate
      length.public_send(length_unit) # rubocop:disable GitlabSecurity/PublicSend
    end

    private

    def valid_ends_at
      errors.add(:ends_at, s_('must be after start')) if ends_at <= starts_at
    end
  end
end
