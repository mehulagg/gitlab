# frozen_string_literal: true
# frozen_string_literal

class Analytics::DevopsAdoption::SegmentSelection < ApplicationRecord
  belongs_to :segment, class_name: "Analytics::DevopsAdoption::Segment"
  belongs_to :project
  belongs_to :group
end
