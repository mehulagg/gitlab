# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class EpicsPipeline
          include ::BulkImports::Pipeline

          extractor ::BulkImports::Common::Extractors::GraphqlExtractor,
            query: EE::BulkImports::Groups::Graphql::GetEpicsQuery

          transformer ::BulkImports::Common::Transformers::HashKeyDigger, key_path: %w[data group epics]
          transformer ::BulkImports::Common::Transformers::UnderscorifyKeysTransformer
          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer

          class Transformer
            def initialize(*); end
            def transform(context, data)
              data = data.with_indifferent_access

              data[:nodes] = Array.wrap(data[:nodes]).map do |entry|
                load_labels(context, entry)
              end

              data
            end

            def load_labels(context, entry)
              entry[:label_ids] = entry.dig(:labels, :nodes).map do |node|
                node[:title]
              end

              entry
            end
          end; transformer Transformer

          loader EE::BulkImports::Groups::Loaders::EpicsLoader

          def after_run(context)
            if context.entity.has_next_page?(:epics)
              run(context)
            end
          end
        end
      end
    end
  end
end
