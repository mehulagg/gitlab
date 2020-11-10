# frozen_string_literal: true

module BulkImports
  module Groups
    module Extractors
      class SubgroupsExtractor
        def initialize(*args); end

        def extract(context)
          encoded_parent_path = ERB::Util.url_encode(context.entity.source_full_path)

          subgroups = []
          http_client(context.entity.bulk_import.configuration)
            .each_page(:get, "groups/#{encoded_parent_path}/subgroups") do |page|
              subgroups << page
            end
          subgroups
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
