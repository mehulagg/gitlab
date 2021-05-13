# frozen_string_literal: true

module Geo
  class ContainerRepositoryUpdatedEvent < NamespaceShard
    include Geo::Model
    include Geo::Eventable

    belongs_to :container_repository

    validates :container_repository, presence: true
  end
end
