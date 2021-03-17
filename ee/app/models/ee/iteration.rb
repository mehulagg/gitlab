# frozen_string_literal: true

module EE
  module Iteration
    extend ActiveSupport::Concern

    STATE_ENUM_MAP = {
      upcoming: 1,
      started: 2,
      closed: 3
    }.with_indifferent_access.freeze

    # For Iteration
    class Predefined
      None = ::Timebox::TimeboxStruct.new('None', 'none', ::Timebox::None.id).freeze
      Any = ::Timebox::TimeboxStruct.new('Any', 'any', ::Timebox::Any.id).freeze
      Current = ::Timebox::TimeboxStruct.new('Current', 'current', -4).freeze

      ALL = [None, Any, Current].freeze
    end

    prepended do
      include AtomicInternalId
      include Timebox

      attr_accessor :skip_future_date_validation
      attr_accessor :skip_project_validation

      belongs_to :project
      belongs_to :group
      belongs_to :iterations_cadence, class_name: '::Iterations::Cadence', foreign_key: :iterations_cadence_id, inverse_of: :iterations

      has_many :issues, foreign_key: 'sprint_id'
      has_many :merge_requests, foreign_key: 'sprint_id'

      has_internal_id :iid, scope: :project
      has_internal_id :iid, scope: :group

      validates :start_date, presence: true
      validates :due_date, presence: true
      validates :iterations_cadence, presence: true, unless: -> { project_id.present? }

      validate :dates_do_not_overlap, if: :start_or_due_dates_changed?
      validate :future_date, if: :start_or_due_dates_changed?, unless: :skip_future_date_validation
      validate :no_project, unless: :skip_project_validation
      validate :validate_group

      before_validation :set_iterations_cadence, unless: -> { project_id.present? }
      before_create :set_past_iteration_state

      scope :upcoming, -> { with_state(:upcoming) }
      scope :started, -> { with_state(:started) }
      scope :closed, -> { with_state(:closed) }

      scope :within_timeframe, -> (start_date, end_date) do
        where('start_date <= ?', end_date).where('due_date >= ?', start_date)
      end

      scope :start_date_passed, -> { where('start_date <= ?', Date.current).where('due_date >= ?', Date.current) }
      scope :due_date_passed, -> { where('due_date < ?', Date.current) }

      state_machine :state_enum, initial: :upcoming do
        event :start do
          transition upcoming: :started
        end

        event :close do
          transition [:upcoming, :started] => :closed
        end

        state :upcoming, value: Iteration::STATE_ENUM_MAP[:upcoming]
        state :started, value: Iteration::STATE_ENUM_MAP[:started]
        state :closed, value: Iteration::STATE_ENUM_MAP[:closed]
      end

      class << self
        alias_method :with_state, :with_state_enum
        alias_method :with_states, :with_state_enums
      end
    end

    class_methods do
      def reference_pattern
        # NOTE: The id pattern only matches when all characters on the expression
        # are digits, so it will match *iteration:2 but not *iteration:2.1 because that's probably a
        # iteration name and we want it to be matched as such.
        @reference_pattern ||= %r{
        (#{::Project.reference_pattern})?
        #{::Regexp.escape(reference_prefix)}
        (?:
          (?<iteration_id>
            \d+(?!\S\w)\b # Integer-based iteration id, or
          ) |
          (?<iteration_name>
            [^"\s]+\b |  # String-based single-word iteration title, or
            "[^"]+"      # String-based multi-word iteration surrounded in quotes
          )
        )
      }x.freeze
      end

      def link_reference_pattern
        @link_reference_pattern ||= super("iterations", /(?<iteration>\d+)/)
      end

      def filter_by_state(iterations, state)
        case state
        when 'closed' then iterations.closed
        when 'started' then iterations.started
        when 'upcoming' then iterations.upcoming
        when 'opened' then iterations.started.or(iterations.upcoming)
        when 'all' then iterations
        else raise ArgumentError, "Unknown state filter: #{state}"
        end
      end
    end

    def state
      STATE_ENUM_MAP.key(state_enum)
    end

    def state=(value)
      self.state_enum = STATE_ENUM_MAP[value]
    end

    def resource_parent
      group || project
    end

    # Show just the title when we manage to find an iteration, without the reference pattern,
    # since it's long and unsightly.
    def reference_link_text(from = nil)
      self.title
    end

    def supports_timebox_charts?
      resource_parent&.feature_available?(:iterations) && weight_available?
    end

    private

    def timebox_format_reference(format = :id)
      raise ::ArgumentError, _('Unknown format') unless [:id, :name].include?(format)

      if format == :name
        super
      else
        id
      end
    end

    def parent_group
      group || project.group
    end

    def start_or_due_dates_changed?
      start_date_changed? || due_date_changed?
    end

    # ensure dates do not overlap with other Iterations in the same cadence tree
    def dates_do_not_overlap
      return unless iterations_cadence
      return unless iterations_cadence.iterations.where.not(id: self.id).within_timeframe(start_date, due_date).exists?

      # for now we only have a single default cadence within a group just to wrap the iterations into a set.
      # once we introduce multiple cadences per group we need to change this message.
      # related issue: https://gitlab.com/gitlab-org/gitlab/-/issues/299312
      errors.add(:base, s_("Iteration|Dates cannot overlap with other existing Iterations within this group"))
    end

    def future_date
      if start_or_due_dates_changed?
        errors.add(:start_date, s_("Iteration|cannot be more than 500 years in the future")) if start_date > 500.years.from_now
        errors.add(:due_date, s_("Iteration|cannot be more than 500 years in the future")) if due_date > 500.years.from_now
      end
    end

    def no_project
      return unless project_id.present?

      errors.add(:project_id, s_("is not allowed. We do not currently support project-level iterations"))
    end

    def set_past_iteration_state
      # if we create an iteration in the past, we set the state to closed right away,
      # no need to wait for IterationsUpdateStatusWorker to do so.
      self.state = :closed if due_date < Date.current
    end

    # TODO: this method should be removed as part of https://gitlab.com/gitlab-org/gitlab/-/issues/296099
    def set_iterations_cadence
      return if iterations_cadence
      # For now we support only group iterations
      # issue to clarify project iterations: https://gitlab.com/gitlab-org/gitlab/-/issues/299864
      return unless group

      # we need this as we use the cadence to validate the dates overlap for this iteration,
      # so in the case this runs before background migration we need to first set all iterations
      # in this group to a cadence before we can validate the dates overlap.
      default_cadence = find_or_create_default_cadence
      group.iterations.where(iterations_cadence_id: nil).update_all(iterations_cadence_id: default_cadence.id)

      self.iterations_cadence = default_cadence
    end

    # TODO: this method should be removed as part of https://gitlab.com/gitlab-org/gitlab/-/issues/296099
    def find_or_create_default_cadence
      cadence_title = "#{group.name} Iterations"
      start_date = self.start_date || Date.today

      ::Iterations::Cadence.create_with(
        title: cadence_title,
        start_date: start_date,
        automatic: false,
        # set to 0, i.e. unspecified when creating default iterations as we do validate for presence.
        iterations_in_advance: 0,
        duration_in_weeks: 0
      ).safe_find_or_create_by!(group: group)
    end

    # TODO: remove this as part of https://gitlab.com/gitlab-org/gitlab/-/issues/296100
    def validate_group
      return if iterations_cadence&.group_id == group_id
      return unless iterations_cadence

      errors.add(:group, s_('is not valid. The iteration group has to match the iteration cadence group.'))
    end
  end
end
