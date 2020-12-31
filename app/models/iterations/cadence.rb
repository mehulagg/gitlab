# frozen_string_literal: true

class Iterations::Cadence < ApplicationRecord
  self.table_name = 'iteration_cadences'

  belongs_to :group
  has_many :iterations, foreign_key: :iteration_cadence_id

  validates :title, presence: true
  validates :start_date, presence: true
  validates :group_id, presence: true

  def self.default_title
    'Iteration cadence'
  end
end
