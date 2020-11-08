# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class SubgroupEntitiesPipeline
        include Pipeline

        extractor do |context|
          path = ERB::Util.url_encode(context.source_full_path)

          context
            .http_client
            .each_page(:get, "groups/#{encoded_parent_path}/subgroups")
            .flat_map(&:itself)
        end

        transformer do |context, entry|
          {
            source_type: :group_entity,
            source_full_path: entry['full_path'],
            destination_name: entry['name'],
            destination_namespace: context.group.full_path,
            parent_id: context.id
          }
        end

        loader do |context, entry|
          context.bulk_import.entities.create!(entry)
        end
      end
    end
  end
end
