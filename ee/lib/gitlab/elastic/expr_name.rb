# frozen_string_literal: true

module Gitlab
  module Elastic
    class ExprName
      def initialize(context)
        @context = context

        @values = []
      end

      def build(*context)
        @values.concat(context)

        self
      end

      def name(*context, &block)
        @context.name(*context, &block)
      end

      def to_s
        @values.map(&:to_s).join(":")
      end

      def to_a
        @values
      end
    end
  end
end
