# frozen_string_literal: true

module Geo
  class LfsObjectLegacyRegistryFinder < FileRegistryFinder
    def registry_class
      Geo::LfsObjectRegistry
    end
  end
end
