# frozen_string_literal: true

module EE
  module Gitlab
    module Search
      module ParsedQuery
        def elasticsearch_filter_context(object)
          {
            filter: including_filters.map { |f| prepare_for_elasticsearch(object, f) },
            must_not: excluding_filters.map { |f| prepare_for_elasticsearch(object, f) }
          }
        end

        private

        def prepare_for_elasticsearch(object, filter)
          type = filter[:type] || :wildcard
          field = filter[:field] || filter[:name]

          {
            type => {
              "#{object}.#{field}" => filter[:value]
            }
          }
        end
      end
    end
  end
end
