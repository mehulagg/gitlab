# frozen_string_literal: true

class Analytics::DevopsAdoption::Segment < ApplicationRecord
  ALLOWED_SEGMENT_COUNT = 20

  has_many :segment_selections, class_name: "Analytics::DevopsAdoption::SegmentSelection"
  has_many :groups, -> { order(:name) }, through: :segment_selections

  validates :name, presence: true, uniqueness: true

  validate :validate_segment_count

  accepts_nested_attributes_for :segment_selections

  private

  def validate_segment_count
    if self.class.count >= ALLOWED_SEGMENT_COUNT
      errors.add(:name, s_('DevopsAdoptionSegment|The maximum number of segments has been reached'))
    end
  end
end
