# frozen_string_literal: true

class ResourceWeightEvent < ResourceEvent
  include IssueResourceEvent

  validates :issue, presence: true
end
