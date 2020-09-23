# frozen_string_literal: true

module EE
  module ContainerRegistry
    module Event
      extend ::Gitlab::Utils::Override

      override :handle!
      def handle!
        super
        create_geo_container_repository_updated_event_store!
      end

      private

      def create_geo_container_repository_updated_event_store!
        return unless media_type_manifest? || target_tag?
        return unless container_repository_exists?

        ::Geo::ContainerRepositoryUpdatedEventStore.new(find_container_repository!)
                                                   .create!
      end

      def media_type_manifest?
        event.dig('target', 'mediaType') =~ /manifest/
      end

      def find_container_repository!
        ::ContainerRepository.find_by_path!(container_registry_path)
      end
    end
  end
end
