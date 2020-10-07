# frozen_string_literal: true

module Types
  module Ci
    class TraceType < BaseObject
      graphql_name 'BuildTrace'

      authorize :read_build_trace

      field :raw, GraphQL::STRING_TYPE, null: true, description: 'The trace as plaintext.' do
        argument :tail, ::GraphQL::INT_TYPE, required: false, description: 'Take only the last N lines.'
      end

      field :html, GraphQL::STRING_TYPE, null: true, description: 'The trace as HTML.' do
        argument :tail, ::GraphQL::INT_TYPE, required: false, description: 'Take only the last N lines.'
      end

      field :sections, [::Types::Ci::TraceSectionType], null: true,
        description: 'The sections in the trace.',
        extras: [:lookahead]

      def raw(tail: nil)
        trace.raw(last_lines: tail)
      end

      def html(tail: nil)
        trace.html(last_lines: tail)
      end

      def sections(lookahead:)
        trace.job.parse_trace_sections!

        sections = trace.job.trace_sections
          .order(byte_start: :asc) # rubocop: disable CodeReuse/ActiveRecord

        if lookahead.selects?(:name)
          sections = sections.preload(:section_name) # rubocop: disable CodeReuse/ActiveRecord
        end

        if lookahead.selects?(:content)
          sections = sections.preload(:build) # rubocop: disable CodeReuse/ActiveRecord
        end

        sections
      end

      alias_method :trace, :object
    end
  end
end
