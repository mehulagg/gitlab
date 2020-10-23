# frozen_string_literal: true

module Banzai
  module Filter
    class NormalizeSourceFilter < HTML::Pipeline::Filter
      UTF8_BOM = "\xEF\xBB\xBF"
      UTF8_BOM_RE = /\A#{UTF8_BOM}/

      def call
        # Remove UTF8_BOM from beginning of source text
        html.sub(UTF8_BOM_RE, '')
      end
    end
  end
end
