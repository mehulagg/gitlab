# frozen_string_literal: true

module Iterations
  class Cadence < ApplicationRecord
    include Gitlab::SQL::Pattern
    include EachBatch

    self.table_name = 'iterations_cadences'

    belongs_to :group
    has_many :iterations, foreign_key: :iterations_cadence_id, inverse_of: :iterations_cadence

    validates :title, presence: true
    validates :start_date, presence: true
    validates :group_id, presence: true
    validates :duration_in_weeks, presence: true, if: ->(cadence) { cadence.automatic? }
    validates :iterations_in_advance, presence: true, if: ->(cadence) { cadence.automatic? }
    validates :active, inclusion: [true, false]
    validates :automatic, inclusion: [true, false]
    validates :description, length: { maximum: 5000 }

    scope :with_groups, -> (group_ids) { where(group_id: group_ids) }
    scope :with_duration, -> (duration) { where(duration_in_weeks: duration) }
    scope :is_automatic, -> (automatic) { where(automatic: automatic) }
    scope :is_active, -> (active) { where(active: active) }
    scope :ordered_by_title, -> { order(:title) }
    scope :for_automated_iterations, -> do
      table = Iterations::Cadence.arel_table
      is_automatic(true)
        .where(table[:duration_in_weeks].gt(0))
        .where(
          table[:last_run_date].eq(nil).or(
            Arel::Nodes::NamedFunction.new('DATE',
              [table[:last_run_date] + table[:duration_in_weeks] * Arel::Nodes::SqlLiteral.new("INTERVAL '1 week'")]
            ).lteq(Arel::Nodes::SqlLiteral.new('CURRENT_DATE'))
          )
        )
    end

    def next_open_iteration(date)
      return unless date

      iterations.without_state_enum(:closed).where('start_date >= ?', date).order(start_date: :asc).first
    end

    def self.search_title(query)
      fuzzy_search(query, [:title])
    end

    def can_be_automated?
      active? && automatic? && duration_in_weeks.to_i > 0 && iterations_in_advance.to_i > 0
    end
  end
end
