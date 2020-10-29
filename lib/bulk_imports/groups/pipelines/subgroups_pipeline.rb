# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class SubgroupsPipeline
        include Pipeline

        class Extractor
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

        class Transformer
          def initialize(*args); end

          def transform(context, data)
            data.map do |entry|
              {
                source_type: :group_entity,
                source_name: entity['name'],
                source_full_path: entity['full_path'],
                destination_name: "SUB IMPORTED #{entity['name']}",
                destination_namespace: context.entity.group
              }
            end
          end
        end

        class Loader
          def initialize(*args); end

          def load(context, data)
            data.each do |entry|
              ::BulkImportService.new(
                context.entity.bulk_import.user,
                entry,
                context.entity.bulk_import.configuration.slice(:url, :access_token)
              )
            end
          end
        end

        extractor Extractor

        transformer Transformer

        loader Loader
      end
    end
  end
end
