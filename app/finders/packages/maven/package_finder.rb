# frozen_string_literal: true

module Packages
  module Maven
    class PackageFinder < ::Packages::GroupOrProjectPackageFinder
      include ::Packages::FinderHelper
      include Gitlab::Utils::StrongMemoize

      def initialize(path, current_user, project: nil, group: nil, order_by_package_file: false)
        @path = path
        @current_user = current_user
        @project_or_group = project || group
        @order_by_package_file = order_by_package_file
      end

      def execute
        packages.last
      end

      def execute!
        packages.last!
      end

      private

      def packages
        matching_packages = base.only_maven_packages_with_path(@path, use_cte: @group.present?)
        matching_packages = matching_packages.order_by_package_file if @order_by_package_file

        matching_packages
      end
    end
  end
end
