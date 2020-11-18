# frozen_string_literal: true

module Gitlab
  module Graphql
    class ConnectionFilterExtension < GraphQL::Schema::FieldExtension
      class Redactor
        def initialize(type, context)
          @type = type
          @context = context
        end

        def redact(nodes)
          @type.remove_unauthorized(nodes, @context)

          nodes
        end

        def active?
          @type && @type.respond_to?(:remove_unauthorized)
        end
      end

      def after_resolve(value:, context:, **rest)
        if @field.connection?
          redact_connection(value, context)
        elsif @field.type.list?
          redact_list(value, context)
        end

        value
      end

      def redact_connection(conn, context)
        redactor = Redactor.new(@field.type.unwrap.node_type, context)
        return unless redactor.active?

        conn.redactor = redactor if conn.respond_to?(:redactor=)
      end

      def redact_list(list, context)
        redactor = Redactor.new(@field.type.unwrap, context)
        redactor.redact(list) if redactor.active?
      end
    end
  end
end
