# frozen_string_literal: true

module IncidentManagement
  class OncallRotation < ApplicationRecord
    include Gitlab::Utils::StrongMemoize

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

    validates :active_period_start, presence: true, if: :active_period_end
    validates :active_period_end, presence: true, if: :active_period_start
    validate :active_period_end_after_start, if: :active_period_start
    validate :no_active_period_for_hourly_shifts, if: :hours?

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

    # The duration of a shift cycle, which is the time until the next participant is on-call.
    # If a shift active period is setup then many shifts will be within a shift_cycle_duration.
    def shift_cycle_duration
      # As length_unit is an enum, input is guaranteed to be appropriate
      length.public_send(length_unit) # rubocop:disable GitlabSecurity/PublicSend
    end

    def shifts_per_cycle
      return 1 unless has_shift_active_period?

      weeks? ? (7 * length) : length
    end

    def has_shift_active_period?
      return false if hours?

      active_period_start.present?
    end

    def active_period_times
      return unless has_shift_active_period?

      strong_memoize(:active_period_times) do
        {
          start: active_period_start.to_time,
          end: active_period_end.to_time
        }
      end
    end

    def active_period(date)
      [
        date.change(hour: active_period_times[:start].hour, min: active_period_times[:start].min),
        date.change(hour: active_period_times[:end].hour, min: active_period_times[:end].min)
      ]
    end

    private

    def active_period_end_after_start
      return unless active_period_start && active_period_end

      unless active_period_end.to_time > active_period_start.to_time
        errors.add(:active_period_end, _('must be later than active period start'))
      end
    end

    def no_active_period_for_hourly_shifts
      if active_period_start || active_period_end
        errors.add(:length_unit, _('Restricted shift times are not available for hourly shifts'))
      end
    end
  end
end
