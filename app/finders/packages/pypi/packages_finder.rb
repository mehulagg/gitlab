# frozen_string_literal: true

module Packages
  module Pypi
    class PackagesFinder < ::Packages::GroupOrPackageFinder
      def execute!
        packages.with_normalized_pypi_name(@params[:package_name])

        raise ActiveRecord::RecordNotFound if packages.empty?

        packages
      end

      private

      def packages
        base.pypi.has_version.processed
      end
    end
  end
end
