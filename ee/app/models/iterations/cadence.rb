# frozen_string_literal: true

module Iterations
  class Cadence < ApplicationRecord
    include Gitlab::SQL::Pattern

    self.table_name = 'iterations_cadences'

    belongs_to :group
    has_many :iterations, foreign_key: :iterations_cadence_id, inverse_of: :iterations_cadence

    validates :title, presence: true
    validates :start_date, presence: true
    validates :group_id, presence: true
    validates :duration_in_weeks, presence: true
    validates :iterations_in_advance, presence: true
    validates :active, inclusion: [true, false]
    validates :automatic, inclusion: [true, false]
    validates :description, length: { maximum: 5000 }

    scope :with_groups, -> (group_ids) { where(group_id: group_ids) }
    scope :with_duration, -> (duration) { where(duration_in_weeks: duration) }
    scope :is_automatic, -> (automatic) { where(automatic: automatic) }
    scope :is_active, -> (active) { where(active: active) }
    scope :ordered_by_title, -> { order(:title) }

    def self.search_title(query)
      fuzzy_search(query, [:title])
    end
  end
end
