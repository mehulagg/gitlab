# frozen_string_literal: true

module Packages
  module Nuget
    class PackageFinder < ::Packages::GroupOrProjectPackageFinder
      MAX_PACKAGES_COUNT = 300

      def initialize(current_user, project_or_group, params)
        super
        @package_name = @params[:package_name]
        @package_version = @params[:package_version]
        @limit = @params[:limit] || MAX_PACKAGES_COUNT
      end

      def execute
        packages.limit_recent(@limit)
      end

      private

      def packages
        result = base.nuget
                     .has_version
                     .processed
                     .with_name_like(@package_name)
        result = result.with_version(@package_version) if @package_version.present?
        result
      end
    end
  end
end
