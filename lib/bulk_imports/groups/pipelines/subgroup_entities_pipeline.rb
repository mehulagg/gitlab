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

        transformer Common::Transformers::ProhibitedAttributesTransformer
        transformer BulkImports::Groups::Transformers::SubgroupToEntityTransformer

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
