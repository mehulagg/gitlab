# frozen_string_literal: true

module Mutations
  module Ci
    class ConfigLint < BaseMutation
      graphql_name 'ConfigLint'

      argument :content, ApolloUploadServer::Upload,
               required: false,
               description: 'Contents of .gitlab-ci.yml'

      field :yaml_processor_result, Types::Ci::YamlProcessorResultType,
            null: true,
            description: 'Result for the YAML processor'

      def resolve(content:)
        result = Gitlab::Ci::YamlProcessor.new(File.read(content)).execute

        {
          yaml_processor_result: result,
          errors: result[:message],
        }

      end
    end
  end
end
