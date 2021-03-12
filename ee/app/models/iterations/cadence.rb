# frozen_string_literal: true

module Iterations
  class Cadence < ApplicationRecord
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
  end
end
