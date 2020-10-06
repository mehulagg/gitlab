# frozen_string_literal: true

module Gitlab
  module BulkImport
    class PipelineContext
      include Gitlab::Utils::LazyAttributes

      Attribute = Struct.new(:name, :type)

      PIPELINE_ATTRIBUTES = [
        Attribute.new(:graphql_query, GraphQL::Client::OperationDefinition),
        Attribute.new(:graphql_variables, Hash)
      ].freeze

      def initialize(args)
        unknown_attributes = args.keys - PIPELINE_ATTRIBUTES.map(&:name)
        raise ArgumentError, "#{unknown_attributes} are not known keys" if unknown_attributes.any?

        @set_values = args.keys

        assign_attributes(args)
      end

      private

      attr_reader :set_values

      PIPELINE_ATTRIBUTES.each do |attr|
        lazy_attr_reader attr.name, type: attr.type
      end

      def assign_attributes(values)
        values.slice(*PIPELINE_ATTRIBUTES.map(&:name)).each do |name, value|
          instance_variable_set("@#{name}", value)
        end
      end
    end
  end
end

