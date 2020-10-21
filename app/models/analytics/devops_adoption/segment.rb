# frozen_string_literal: true

class Analytics::DevopsAdoption::Segment < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
