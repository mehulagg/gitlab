# frozen_string_literal: true

module Geo
  class LfsObjectRegistryFinder < FileRegistryFinder
    def registry_class
      Geo::LfsObjectRegistry
    end
  end
end
