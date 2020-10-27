# frozen_string_literal: true

# Fetch and persist `BulkImports::Entity` objects with
# source_type: 'group_entity' while preserving parent-child
# relationship and updating destination namespace for each descendant
# based on top level group name & destination namespace
#
# The whole process consists of the following steps:
# 1. Fetch group descendants based on `entity.source_full_path` via `BulkImports::Clients::Http`
# 2. Create `BulkImports::Entity` objects (with placeholder `destination_namespace`)
# 3. For each of created entities, update `parent_id` to restore ancestry tree
# 4. For each of created entities, build `destination_namespace` based on ancestry tree
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
      set_entities_parent
      set_entities_destination_namespace
    end

    private

    def fetch_descendants
      http_client.each_page(:get, "groups/#{@encoded_full_path}/descendant_groups") do |page|
        @group_descendants << page
      end

      @group_descendants.flatten!
    end

    # Destination namespace requires parent (as well as top level ancestor)
    # to be present in order to build correct full path. Setting destination namespace
    # is done in the future step (#set_entities_destination_namespace).
    # Set destination namespace to '-' for the time being (in order to not have NULL as value)
    def create_entities
      @group_descendants.each do |descendant|
        @created_entities[descendant['id']] = BulkImports::Entity.create!(
          bulk_import: @bulk_import,
          source_type: 'group_entity',
          source_full_path: descendant['full_path'],
          destination_name: descendant['name'],
          destination_namespace: '-'
        )
      end
    end

    # Preserve ancestry tree after fetching it from source
    # by updating parent_id on each of the created entities
    def set_entities_parent
      @group_descendants.each do |descendant|
        descendant_entity = @created_entities[descendant['id']]

        if descendant['parent_id'] == source_top_level_group['id']
          descendant_entity.update!(parent_id: @entity.id)
        else
          parent = @created_entities[descendant['parent_id']]

          descendant_entity.update!(parent_id: parent.id) if parent
        end
      end
    end

    # Build destination namespace for each of the entities
    # based on object hierarchy & top level ancestor
    # destination name + namespace
    #
    # An entity destination namespace is built of the following strings:
    # 1. Top level ancestor (parent_id: nil) destination namespace
    # 2. Each ancestor's (including top level one) destination name (parameterized into path)
    def set_entities_destination_namespace
      @created_entities.each_value do |entity|
        ancestors = Gitlab::ObjectHierarchy
          .new(BulkImports::Entity.where(id: entity.id))
          .ancestors(hierarchy_order: :asc)

        top_level_ancestor = ancestors.find_by_parent_id(nil)

        destination_namespace = ancestors
          .pluck(:destination_name)
          .map(&:parameterize)
          .push(top_level_ancestor&.destination_namespace)
          .reverse
          .join('/')

        entity.update!(destination_namespace: destination_namespace)
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
