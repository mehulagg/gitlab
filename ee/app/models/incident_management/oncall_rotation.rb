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

    validates :interval_start, presence: true, if: :interval_end
    validates :interval_end, presence: true, if: :interval_start
    validate :interval_end_after_interval_start, if: :interval_start
    validate :no_interval_for_hourly_shifts, if: :hours?

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
    # If a shift interval is setup then many shifts will be within a shift_cycle_duration.
    def shift_cycle_duration
      # As length_unit is an enum, input is guaranteed to be appropriate
      length.public_send(length_unit) # rubocop:disable GitlabSecurity/PublicSend
    end

    def shifts_per_cycle
      return 1 unless has_shift_intervals?

      weeks? ? (7 * length) : length
    end

    def has_shift_intervals?
      return false if hours?

      interval_start.present?
    end

    def interval_times
      return unless has_shift_intervals?

      strong_memoize(:interval_times) do
        {
          start: interval_start.to_time,
          end: interval_end.to_time
        }
      end
    end

    def unrestricted_interval(date)
      [
        date.change(hour: interval_times[:start].hour, min: interval_times[:start].min),
        date.change(hour: interval_times[:end].hour, min: interval_times[:end].min)
      ]
    end

    private

    def interval_end_after_interval_start
      return unless interval_start && interval_end

      unless interval_end.to_time > interval_start.to_time
        errors.add(:interval_end, _('must be later than interval start'))
      end
    end

    def no_interval_for_hourly_shifts
      if interval_start || interval_end
        errors.add(:length_unit, _('Restricted shift times are not available for hourly shifts'))
      end
    end
  end
end
