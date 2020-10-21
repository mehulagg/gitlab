# frozen_string_literal: true

class Analytics::DevopsAdoption::Segment < ApplicationRecord
  has_many :segment_selections, class_name: "Analytics::DevopsAdoption::SegmentSelection"

  validates :name, presence: true, uniqueness: true
end
