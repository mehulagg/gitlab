# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class SubgroupEntitiesPipeline
        include Pipeline

        def extract(context)
          encoded_parent_path = ERB::Util.url_encode(context.entity.source_full_path)

          http_client(context.entity.bulk_import.configuration)
            .each_page(:get, "groups/#{encoded_parent_path}/subgroups")
            .flat_map(&:itself)
        end

        def transform(context, entry)
          clean_prohibited_attributes(context, entry).then do |entry|
            {
              source_type: :group_entity,
              source_full_path: entry['full_path'],
              destination_name: entry['name'],
              destination_namespace: context.entity.group.full_path,
              parent_id: context.entity.id
            }
          end
        end

        def load(context, entry)
          context.entity.bulk_import.entities.create!(entry)
        end

        private

        def http_client(configuration)
          @http_client ||= BulkImports::Clients::Http.new(
            uri: configuration.url,
            token: configuration.access_token,
            per_page: 100
          )
        end
      end
    end
  end
end
