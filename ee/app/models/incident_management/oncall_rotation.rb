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
    # Note! If changing the order of participants, also change the :with_shift_generation_associations scope.
    has_many :participants, -> { order(id: :asc) }, class_name: 'OncallParticipant', inverse_of: :rotation
    has_many :users, through: :participants
    has_many :shifts, class_name: 'OncallShift', inverse_of: :rotation, foreign_key: :rotation_id

    validates :name, presence: true, uniqueness: { scope: :oncall_schedule_id }, length: { maximum: NAME_LENGTH }
    validates :starts_at, presence: true
    validates :length, presence: true, numericality: true
    validates :length_unit, presence: true

    scope :started, -> { where('starts_at < ?', Time.current) }
    scope :except_ids, -> (ids) { where.not(id: ids) }
    scope :with_shift_generation_associations, -> do
      joins(:participants, :schedule)
        .distinct
        .includes(:participants, :schedule)
       .order(:id, 'incident_management_oncall_participants.id ASC')
    end

    delegate :project, to: :schedule

    def self.pluck_id_and_user_id
      joins(shifts: { participant: :user }).pluck(:id, 'users.id')
    end

    def shift_duration
      # As length_unit is an enum, input is guaranteed to be appropriate
      length.public_send(length_unit) # rubocop:disable GitlabSecurity/PublicSend
    end
  end
end
