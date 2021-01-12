# frozen_string_literal: true

module Banzai
  module Filter
    class TruncateSourceFilter < HTML::Pipeline::Filter
      def call
        return html unless context.key?(:limit)

        Truncato.truncate(html, max_length: context[:limit], count_tags: false)
      end
    end
  end
end
