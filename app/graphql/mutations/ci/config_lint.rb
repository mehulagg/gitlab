# frozen_string_literal: true

module Mutations
  module Ci
    class ConfigLint < BaseMutation
      graphql_name 'ConfigLint'

      argument :content, ApolloUploadServer::Upload,
               required: false,
               description: 'Contents of .gitlab-ci.yml'

      argument :include_merged_yaml, GraphQL::BOOLEAN_TYPE,
                required: false,
                description: 'Whether or not to include merged CI yaml in the response'

      field :yaml_processor_result, Types::Ci::YamlProcessorResultType,
            null: true,
            description: 'Result for the YAML processor'

      def resolve(content:, include_merged_yaml: false)
        result = Gitlab::Ci::YamlProcessor.new(File.read(content)).execute

        error = result.errors.first

        response = if error.blank?
                     { status: 'valid', errors: [] }
                   else
                     { status: 'invalid', errors: [error] }
                   end

        response.tap do |response|
          response[:merged_yaml] = result.merged_yaml if include_merged_yaml
        end

        {
          yaml_processor_result: result,
          errors: []
        }

      end
    end
  end
end
