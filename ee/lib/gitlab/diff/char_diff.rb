# frozen_string_literal: true

module Gitlab
  module Diff
    class CharDiff
      include Gitlab::Utils::StrongMemoize

      def initialize(old_string, new_string)
        @old_string = old_string.to_s
        @new_string = new_string.to_s
        @changes = []
      end

      def generate_diff
        @changes = diff_match_patch.diff_main(@old_string, @new_string)
        diff_match_patch.diff_cleanupSemantic(@changes)

        @changes
      end

      def to_html
        @changes.map do |op, text|
          %{<span class="#{html_class_names(op)}">#{ERB::Util.html_escape(text)}</span>}
        end.join.html_safe
      end

      private

      def diff_match_patch
        strong_memoize(:diff_match_patch) { DiffMatchPatch.new }
      end

      def html_class_names(operation)
        class_names = ['idiff']

        case operation
        when :insert
          class_names << 'addition'
        when :delete
          class_names << 'deletion'
        end

        class_names.join(' ')
      end
    end
  end
end
