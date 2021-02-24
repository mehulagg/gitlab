# frozen_string_literal: true

require 'securerandom'

module QA
  module Resource
    class Package < Base
      attr_accessor :name,
                    :package_id

      attribute :project do
        Project.fabricate_via_api! do |resource|
          resource.name = 'project-with-package'
          resource.description = 'Project with Package'
        end
      end

      def initialize
        @name = "package-#{SecureRandom.hex(4)}"
        @package_id = nil
      end

      def fabricate!
      end

      def fabricate_via_api!
        resource_web_url(api_get)
      rescue ResourceNotFoundError
        super
      end

      def remove_via_api!
        packages = project.packages
        if packages && !packages.empty?
          this_package = packages.find { |package| package[:name] == name }

          @package_id = this_package[:id]

          QA::Runtime::Logger.debug("Deleting package '#{name}' from '#{project.path_with_namespace}'")
          super
        end
      end

      def api_delete_path
        "/projects/#{project.id}/packages/#{@package_id}"
      end

      def api_get_path
        "/projects/#{project.id}/packages"
      end
    end
  end
end
