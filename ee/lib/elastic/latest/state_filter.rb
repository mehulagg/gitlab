# frozen_string_literal: true

module Elastic
  module Latest
    module StateFilter
      private

      def state_filter(query_hash, options)
        state = options[:state]

        return query_hash if state.blank? || state == 'all'
        return query_hash unless API::Helpers::SearchHelpers.search_states.include?(state)

        filter = { match: { state: state } }

        query_hash[:query][:bool][:filter] << filter
        query_hash
      end
    end
  end
end
