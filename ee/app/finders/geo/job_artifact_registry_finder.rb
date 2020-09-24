# frozen_string_literal: true

module Geo
  class JobArtifactRegistryFinder < FileRegistryFinder
    def registry_class
      Geo::JobArtifactRegistry
    end
  end
end
