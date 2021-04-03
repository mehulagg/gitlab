# frozen_string_literal: true

module Geo
  class AttachmentRegistryFinder < FileRegistryFinder
    def registry_class
      Geo::UploadRegistry
    end
  end
end
