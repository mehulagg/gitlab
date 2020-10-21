# frozen_string_literal: true

class ResourceIterationEvent < ResourceTimeboxEvent
  belongs_to :iteration

  scope :with_api_entity_associations, -> { preload(:iteration, :user) }
end
