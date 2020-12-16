# frozen_string_literal: true

class Analytics::DevopsAdoption::Segment < ApplicationRecord
  ALLOWED_SEGMENT_COUNT = 20

  has_many :segment_selections
  has_many :groups, through: :segment_selections
  has_many :projects, through: :segment_selections
  has_many :snapshots, inverse_of: :segment
  has_one :latest_snapshot, -> { order(recorded_at: :desc) }, inverse_of: :segment, class_name: 'Snapshot'

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validate :validate_segment_count, on: :create

  accepts_nested_attributes_for :segment_selections, allow_destroy: true

  scope :ordered_by_name, -> { order(:name) }
  scope :with_groups, -> { preload(:groups) }

  private

  def validate_segment_count
    if self.class.count >= ALLOWED_SEGMENT_COUNT
      errors.add(:name, s_('DevopsAdoptionSegment|The maximum number of segments has been reached'))
    end
  end
end
