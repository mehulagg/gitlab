# frozen_string_literal: true

class IterationCadence < ApplicationRecord
  belongs_to :group
  has_many :iterations

  validates :title, presence: true
  validates :start_date, presence: true
  validates :group_id, presence: true

  def self.default_title
    'Iteration cadence'
  end
end
