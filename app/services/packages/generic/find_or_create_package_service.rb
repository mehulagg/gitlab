# frozen_string_literal: true

module Packages
  module Generic
    class FindOrCreatePackageService < ::Packages::CreatePackageService
      def execute
        package_type = ::Packages::Package.package_types['generic']
        if params[:internal].present?
          package_type = ::Packages::Package.package_types['internal']
        end

        find_or_create_package!(package_type) do |package|
          if params[:build].present?
            package.build_infos.new(pipeline: params[:build].pipeline)
          end
        end
      end
    end
  end
end
