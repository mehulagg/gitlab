# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class EpicsPipeline
          include ::BulkImports::Pipeline

          extractor ::BulkImports::Common::Extractors::GraphqlExtractor,
            query: EE::BulkImports::Groups::Graphql::GetEpicsQuery

          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer
          transformer ::BulkImports::Common::Transformers::UserReferenceTransformer, reference: 'author'
          transformer EE::BulkImports::Groups::Transformers::EpicAttributesTransformer

          def transform(_, data)
            cache_epic_source_params(data)
          end

          def load(context, data)
            raise ::BulkImports::Pipeline::NotAllowedError unless authorized?

            context.group.epics.create!(data)
          end

          private

          def authorized?
            context.current_user.can?(:admin_epic, context.group)
          end

          def cache_epic_source_params(data)
            source_id = GlobalID.parse(data['id'])&.model_id
            source_iid = data['iid']

            if source_id
              cache_key = "bulk_import:#{context.bulk_import.id}:entity:#{context.entity.id}:epic:#{source_iid}"
              source_params = { source_id: source_id }

              ::Gitlab::Redis::Cache.with do |redis|
                redis.set(cache_key, source_params.to_json, ex: ::BulkImports::Pipeline::CACHE_KEY_EXPIRATION)
              end
            end

            data
          end
        end
      end
    end
  end
end
