# frozen_string_literal: true

module Geo
  class DesignRegistryFinder < RegistryFinder
    def registry_class
      Geo::DesignRegistry
    end
  end
end
