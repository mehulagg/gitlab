# frozen_string_literal: true

module Elastic
  module Latest
    class MergeRequestClassProxy < ApplicationClassProxy
      include StateFilter

      def elastic_search(query, options: {})
        query_hash =
          if query =~ /\!(\d+)\z/
            iid_query_hash(Regexp.last_match(1))
          else
            # iid field can be added here as lenient option will
            # pardon format errors, like integer out of range.
            fields = %w[iid^3 title^2 description]

            basic_query_hash(fields, query, count_only: options[:count_only])
          end

        options[:features] = 'merge_requests'
        context.name(:merge_request) do
          query_hash = context.name(:authorized) { project_ids_filter(query_hash, options) }
          query_hash = context.name(:match) { state_filter(query_hash, options) }
        end
        query_hash = apply_sort(query_hash, options)

        search(query_hash, options)
      end
    end
  end
end
