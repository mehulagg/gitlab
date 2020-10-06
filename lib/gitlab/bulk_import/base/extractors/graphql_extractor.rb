# frozen_string_literal: true

module Gitlab::BulkImport::Base::Extractors
  class GraphqlExtractor

    def self.transform(data)
      data = data.deep_dup['data']['project']

      clean_edges_and_nodes(data)
    end

    def self.clean_edges_and_nodes(data)
      if data.is_a?(Hash)
        data.each do |key, value|
          if data[key].is_a?(Array)
            data[key].map(&method(:clean_edges_and_nodes))
          elsif value.is_a?(Hash) && value.has_key?('edges')
            data[key] = value['edges'].map { |i| i['node']}

            clean_edges_and_nodes(data[key])
          else
            data[key] = value
          end
        end
      end

      if data.is_a?(Array)
        data.map(&method(:clean_edges_and_nodes))
      end

      data
    end
  end
end
