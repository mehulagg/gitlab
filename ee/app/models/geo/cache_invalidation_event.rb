# frozen_string_literal: true

module Geo
  class CacheInvalidationEvent < NamespaceShard
    include Geo::Model
    include Geo::Eventable

    validates :key, presence: true
  end
end
