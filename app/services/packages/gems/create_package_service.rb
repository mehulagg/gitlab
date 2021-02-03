# frozen_string_literal: true

module Packages
  module Gems
    class CreatePackageService < ::Packages::CreatePackageService
      TEMPORARY_PACKAGE_NAME = 'Gem.Temporary.Package'
      PACKAGE_VERSION = '0.0.0'

      def execute
        create_package!(:gem,
          name: TEMPORARY_PACKAGE_NAME,
          version: "#{PACKAGE_VERSION}-#{uuid}"
        )
      end

      private

      def uuid
        SecureRandom.uuid
      end
    end
  end
end
