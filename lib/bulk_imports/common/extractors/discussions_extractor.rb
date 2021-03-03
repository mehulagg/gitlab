# frozen_string_literal: true

module BulkImports
  module Common
    module Extractors
      class DiscussionsExtractor < GraphqlExtractor
        def extract(context)
          client = graphql_client(context)

          response = client.execute(
            client.parse(query.to_s),
            variables(context)
          ).original_hash.deep_dup

          BulkImports::Pipeline::ExtractedData.new(
            data: data(response, context),
            page_info: page_info(response, context)
          )
        end

        private

        def variables(context)

        end

        def data(response, context)

        end

        def page_info(response, context)
          {
          }
        end
      end
    end
  end
end
