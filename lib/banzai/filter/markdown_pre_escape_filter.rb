# frozen_string_literal: true

module Banzai
  module Filter
    class MarkdownPreEscapeFilter < HTML::Pipeline::TextFilter
      ASCII_PUNCTUATION = /([\\][!"#$%&'()*+,-.\/:;<=>?@\[\\\]^_`{|}~])/.freeze

      # Converts backslash escaped ASCII punctuation into a custom html tag.
      # This way CommonMark will properly handle the backslash escaped chars
      # but we will maintain knowledge (the tag) that it was a literal.
      # So we don't treat them as references or other shortcut characters.
      # https://spec.commonmark.org/0.29/#backslash-escapes
      def call
        @text.gsub(ASCII_PUNCTUATION, '<gl-literal>\1</gl-literal>')
      end
    end
  end
end
