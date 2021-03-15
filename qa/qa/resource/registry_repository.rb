# frozen_string_literal: true

require 'securerandom'

module QA
  module Resource
    class RegistryRepository < Base
      attr_accessor :name,
                    :repository_id,
                    :tag_name

      attribute :project do
        Project.fabricate_via_api! do |resource|
          resource.name = 'project-with-registry'
          resource.description = 'Project with Registry'
        end
      end

      def initialize
        @name = project.path_with_namespace
        @repository_id = nil
        @tag_name = 'master'
      end

      def fabricate!
      end

      def fabricate_via_api!
        resource_web_url(api_get)
      rescue ResourceNotFoundError
        super
      end

      def remove_via_api!
        registry_repositories = project.registry_repositories
        if registry_repositories && !registry_repositories.empty?
          this_registry_repository = registry_repositories.find { |registry_repository| registry_repository[:path] == name }

          @repository_id = this_registry_repository[:id]

          QA::Runtime::Logger.debug("Deleting registry '#{name}'")
          super
        end
      end

      def api_delete_path
        "/projects/#{project.id}/registry/repositories/#{@repository_id}"
      end

      def api_delete_tag_path
        "/projects/#{project.id}/registry/repositories/#{@repository_id}/tags/#{@tag_name}"
      end

      def api_get_path
        "/projects/#{project.id}/registry/repositories"
      end

      def api_get_tags_path
        "/projects/#{project.id}/registry/repositories/#{@repository_id}/tags"
      end

      def has_tag?(tag_name)
        response = get Runtime::API::Request.new(api_client, api_get_tags_path).url

        raise ResourceNotFoundError, "Request returned (#{response.code}): `#{response}`." if response.code == HTTP_STATUS_NOT_FOUND

        tag_list = parse_body(response)
        tag_list.any? { |tag| tag[:name] == tag_name }
      end

      def delete_tag
        QA::Runtime::Logger.debug("Deleting registry tag '#{tag_name}'")
        request = Runtime::API::Request.new(api_client, api_delete_tag_path)
        response = delete(request.url)

        unless [HTTP_STATUS_NO_CONTENT, HTTP_STATUS_ACCEPTED].include? response.code
          raise ResourceNotDeletedError, "Resource at #{request.mask_url} could not be deleted (#{response.code}): `#{response}`."
        end
      end
    end
  end
end
