# frozen_string_literal: true

module BulkImports
  module Pipeline
    class Context
      include Gitlab::Utils::LazyAttributes

      Attribute = Struct.new(:name, :type)

      PIPELINE_ATTRIBUTES = [
        Attribute.new(:current_user, User),
        Attribute.new(:entities, Array),
        Attribute.new(:configuration, ::BulkImports::Configuration)
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
