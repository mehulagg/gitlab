# frozen_string_literal: true

module BulkImports
  class SubgroupEntitiesCreator
    def initialize(entity_id)
      @entity = BulkImports::Entity.find(entity_id)
      @bulk_import = @entity.bulk_import
      @encoded_full_path = ERB::Util.url_encode(@entity.source_full_path)
      @group_descendants = []
      @created_entities = {}
    end

    def execute
      fetch_descendants
      create_entities
      update_entities_parent
    end

    private

    def fetch_descendants
      http_client.each_page(:get, "groups/#{@encoded_full_path}/descendant_groups") do |page|
        @group_descendants << page
      end

      @group_descendants.flatten!
    end

    def create_entities
      @group_descendants.each do |descendant|
        destination_namespace = descendant['full_path'].gsub(@entity.source_full_path, @entity.destination_namespace)

        @created_entities[descendant['id']] = BulkImports::Entity.create!(
          bulk_import: @bulk_import,
          source_type: 'group_entity',
          source_full_path: descendant['full_path'],
          destination_name: descendant['name'],
          destination_namespace: destination_namespace
        )
      end
    end

    def update_entities_parent
      @group_descendants.each do |descendant|
        descendant_entity = @created_entities[descendant['id']]

        if descendant['parent_id'] == source_top_level_group['id']
          descendant_entity.update(parent_id: @entity.id)
        else
          parent = @created_entities[descendant['parent_id']]

          descendant_entity.update(parent_id: parent.id) if parent
        end
      end
    end

    def source_top_level_group
      @source_top_level_group ||= http_client.get("groups/#{@encoded_full_path}").parsed_response
    end

    def http_client
      @http_client ||= BulkImports::Clients::Http.new(
        uri: @bulk_import.configuration.url,
        token: @bulk_import.configuration.access_token,
        per_page: 100
      )
    end
  end
end
