# frozen_string_literal: true

module IncidentManagement
  class OncallShift < ApplicationRecord
    self.table_name = 'incident_management_oncall_shifts'

    belongs_to :rotation, class_name: 'OncallRotation', inverse_of: :shifts, foreign_key: :rotation_id
    belongs_to :participant, class_name: 'OncallParticipant', inverse_of: :shifts, foreign_key: :participant_id

    validates :rotation, presence: true
    validates :participant, presence: true
    validates :starts_at, presence: true
    validates :ends_at, presence: true
    validate :timeframes_do_not_overlap, if: :rotation

    scope :for_timeframe, -> (starts_at, ends_at) do
      where("tstzrange(starts_at, ends_at, '[)') && tstzrange(?, ?, '[)')", starts_at, ends_at)
    end

    private

    def timeframes_do_not_overlap
      return unless rotation.shifts.where.not(id: id).for_timeframe(starts_at, ends_at).exists?

      errors.add(:base, 'Shift timeframe cannot overlap with other existing shifts')
    end
  end
end
