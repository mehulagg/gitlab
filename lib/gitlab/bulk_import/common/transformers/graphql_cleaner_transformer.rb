# frozen_string_literal: true

# Cleanup GraphQL original response hash from unnecessary nesting
# 1. Remove ['data']['group'] or ['data']['project'] hash nesting
# 2. Remove ['edges'] & ['nodes'] array wrappings
# 3. Remove ['node'] hash wrapping
#
# @example
#   data = {"data"=>{"group"=> {
#     "name"=>"test",
#     "fullName"=>"test",
#     "description"=>"test",
#     "labels"=>{"edges"=>[{"node"=>{"title"=>"label1"}}, {"node"=>{"title"=>"label2"}}, {"node"=>{"title"=>"label3"}}]}}}}
#
#  Gitlab::BulkImport::Common::Transformers::GraphqlCleanerTransformer.transform(nil, data)
#
#  {"name"=>"test", "fullName"=>"test", "description"=>"test", "labels"=>[{"title"=>"label1"}, {"title"=>"label2"}, {"title"=>"label3"}]}
module Gitlab
  module BulkImport
    module Common
      module Transformers
        class GraphqlCleanerTransformer
          class << self
            def transform(_, data)
              data = data.dig('data', 'group') || data.dig('data', 'project')

              clean_edges_and_nodes(data)
            end

            def clean_edges_and_nodes(data)
              if data.is_a?(Hash)
                data.each do |key, value|
                  if data[key].is_a?(Array)
                    data[key].map(&method(:clean_edges_and_nodes))
                  elsif value.is_a?(Hash) && value.has_key?('edges')
                    data[key] = value['edges'].map { |i| i['node'] }

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
      end
    end
  end
end
