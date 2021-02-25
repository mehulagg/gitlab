# frozen_string_literal: true

module Packages
  module Maven
    module Metadata
      FILENAME = ::Packages::Maven::FindOrCreatePackageService::MAVEN_METADATA_FILE

      def self.filename
        FILENAME
      end
    end
  end
end
