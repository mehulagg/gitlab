# frozen_string_literal: true

class IterationCadence < ApplicationRecord
  belongs_to :group
  has_many :iterations

  validates :title, presence: true
  validates :start_date, presence: true
end
