# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable GraphQL/AuthorizeTypes
    class TraceType < BaseObject
      graphql_name 'Trace'

      # Only accessible through pipeline
      # authorize :read_pipeline

      field :raw, GraphQL::STRING_TYPE, null: true,
            description: 'The trace as plaintext' do
        argument :tail, ::GraphQL::INT_TYPE, required: false,
          description: 'Take only the last N lines'
      end

      field :html, GraphQL::STRING_TYPE, null: true,
            description: 'The trace as HTML' do
        argument :tail, ::GraphQL::INT_TYPE, required: false,
          description: 'Take only the last N lines'
      end

      field :sections, [::Types::Ci::TraceSectionType], null: false,
            description: 'The sections in the trace'

      def raw(tail:)
        trace.raw(last_lines: tail)
      end

      def html(tail:)
        trace.html(last_lines: tail)
      end

      def sections
        trace.extract_sections
      end

      alias_method :trace, :object
    end
    # rubocop: enable GraphQL/AuthorizeTypes
  end
end
