# frozen_string_literal: true

module Packages
  module Rubygems
    class DependencyResolverService < BaseService
      include Gitlab::Utils::StrongMemoize

      DEFAULT_PLATFORM = 'ruby'

      def execute
        return ServiceResponse.error(message: "#{gem_name} not found", http_status: 401) unless package
        return ServiceResponse.error(message: "forbidden", http_status: 403) unless Ability.allowed?(current_user, :read_package, project)

        dependencies = package.dependency_links.map do |link|
          [link.dependency.name, link.dependency.version_pattern]
        end

        payload = {
          platform: DEFAULT_PLATFORM,
          dependencies: dependencies,
          name: gem_name,
          number: package.version
        }

        ServiceResponse.success(payload: payload)
      end

      private

      def package
        strong_memoize(:package) do
          project.packages.with_name(gem_name).last
        end
      end

      def gem_name
        params[:gem_name]
      end
    end
  end
end
