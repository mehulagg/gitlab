# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    # This is only accessible through a build
    class TraceType < BaseObject
      graphql_name 'BuildTrace'

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

      field :sections, [::Types::Ci::TraceSectionType], null: true,
            description: 'The sections in the trace',
            extras: [:lookahead]

      def raw(tail: nil)
        trace.raw(last_lines: tail)
      end

      def html(tail: nil)
        trace.html(last_lines: tail)
      end

      def sections(lookahead:)
        sections = trace.extract_sections

        if lookahead.selects?(:content)
          sections.each { |s| section_content(s) }
        end

        sections
      end

      def section_content(section)
        @raw_bytes ||= trace.raw.bytes.to_a

        section[:content] = @raw_bytes[section[:byte_start]..section[:byte_end]].pack('C*')
      end

      alias_method :trace, :object
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
