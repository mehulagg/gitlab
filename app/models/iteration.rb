# frozen_string_literal: true

class Iteration < ApplicationRecord
  self.table_name = 'sprints'

  attr_accessor :skip_future_date_validation
  attr_accessor :skip_project_validation

  STATE_ENUM_MAP = {
      upcoming: 1,
      started: 2,
      closed: 3
  }.with_indifferent_access.freeze

  include AtomicInternalId

  belongs_to :project
  belongs_to :group
  belongs_to :iterations_cadence, class_name: 'Iterations::Cadence', foreign_key: :iterations_cadence_id, inverse_of: :iterations

  has_internal_id :iid, scope: :project
  has_internal_id :iid, scope: :group

  validates :start_date, presence: true
  validates :due_date, presence: true

  validate :dates_do_not_overlap, if: :start_or_due_dates_changed?
  validate :future_date, if: :start_or_due_dates_changed?, unless: :skip_future_date_validation
  validate :no_project, unless: :skip_project_validation
  validate :validate_group

  before_create :set_iterations_cadence

  scope :upcoming, -> { with_state(:upcoming) }
  scope :started, -> { with_state(:started) }
  scope :closed, -> { with_state(:closed) }

  scope :within_timeframe, -> (start_date, end_date) do
    where('start_date IS NOT NULL OR due_date IS NOT NULL')
      .where('start_date IS NULL OR start_date <= ?', end_date)
      .where('due_date IS NULL OR due_date >= ?', start_date)
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

  # Alias to state machine .with_state_enum method
  # This needs to be defined after the state machine block to avoid errors
  class << self
    alias_method :with_state, :with_state_enum
    alias_method :with_states, :with_state_enums

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

    def reference_prefix
      '*iteration:'
    end

    def reference_pattern
      nil
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

  private

  def parent_group
    group || project.group
  end

  def start_or_due_dates_changed?
    start_date_changed? || due_date_changed?
  end

  # ensure dates do not overlap with other Iterations in the same group/project tree
  def dates_do_not_overlap
    iterations = if parent_group.present? && resource_parent.is_a?(Project)
                   Iteration.where(group: parent_group.self_and_ancestors).or(project.iterations)
                 elsif parent_group.present?
                   Iteration.where(group: parent_group.self_and_ancestors)
                 else
                   project.iterations
                 end

    return unless iterations.where.not(id: self.id).within_timeframe(start_date, due_date).exists?

    errors.add(:base, s_("Iteration|Dates cannot overlap with other existing Iterations"))
  end

  # ensure dates are in the future
  def future_date
    if start_date_changed?
      errors.add(:start_date, s_("Iteration|cannot be in the past")) if start_date < Date.current
      errors.add(:start_date, s_("Iteration|cannot be more than 500 years in the future")) if start_date > 500.years.from_now
    end

    if due_date_changed?
      errors.add(:due_date, s_("Iteration|cannot be in the past")) if due_date < Date.current
      errors.add(:due_date, s_("Iteration|cannot be more than 500 years in the future")) if due_date > 500.years.from_now
    end
  end

  def no_project
    return unless project_id.present?

    errors.add(:project_id, s_("is not allowed. We do not currently support project-level iterations"))
  end

  # TODO: this method should be removed as part of https://gitlab.com/gitlab-org/gitlab/-/issues/296099
  def set_iterations_cadence
    return if iterations_cadence
    # For now we support only group iterations
    # issue to clarify project iterations: https://gitlab.com/gitlab-org/gitlab/-/issues/299864
    return unless group

    self.iterations_cadence = group.iterations_cadences.first || create_default_cadence
  end

  def create_default_cadence
    cadence_title = "#{group.name} Iterations"

    Iterations::Cadence.create!(group: group, title: cadence_title, start_date: start_date)
  end

  # TODO: remove this as part of https://gitlab.com/gitlab-org/gitlab/-/issues/296100
  def validate_group
    return unless iterations_cadence
    return if iterations_cadence.group_id == group_id

    errors.add(:group, s_('is not valid. The iteration group has to match the iteration cadence group.'))
  end
end

Iteration.prepend_if_ee('EE::Iteration')
