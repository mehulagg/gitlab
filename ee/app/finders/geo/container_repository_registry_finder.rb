# frozen_string_literal: true

module Geo
  class ContainerRepositoryRegistryFinder < RegistryFinder
    def registry_class
      Geo::ContainerRepositoryRegistry
    end
  end
end
