# frozen_string_literal: true

module Gitlab
  module Diff
    class Highlight
      attr_reader :diff_file, :diff_lines, :raw_lines, :repository, :project

      delegate :old_path, :new_path, :old_sha, :new_sha, to: :diff_file, prefix: :diff

      def initialize(diff_lines, repository: nil)
        @repository = repository
        @project = repository&.project

        if diff_lines.is_a?(Gitlab::Diff::File)
          @diff_file = diff_lines
          @diff_lines = @diff_file.diff_lines
        else
          @diff_lines = diff_lines
        end

        @raw_lines = @diff_lines.map(&:text)
      end

      def highlight
        @diff_lines.map.with_index do |diff_line, i|
          diff_line = diff_line.dup
          # ignore highlighting for "match" lines
          next diff_line if diff_line.meta?

          rich_line = apply_syntax_highlight(diff_line)

          if line_inline_diffs = inline_diffs[i]
            begin
              rich_line = InlineDiffMarker.new(diff_line.text, rich_line).mark(line_inline_diffs)
            # This should only happen when the encoding of the diff doesn't
            # match the blob, which is a bug. But we shouldn't fail to render
            # completely in that case, even though we want to report the error.
            rescue RangeError => e
              Gitlab::ErrorTracking.track_and_raise_for_dev_exception(e, issue_url: 'https://gitlab.com/gitlab-org/gitlab-foss/issues/45441')
            end
          end

          diff_line.rich_text = rich_line

          diff_line
        end
      end

      private

      def apply_syntax_highlight(diff_line)
        highlight_syntax(diff_line) || ERB::Util.html_escape(diff_line.text)
      end

      def highlight_syntax(diff_line)
        return unless diff_file && diff_file.diff_refs

        syntax_highlight.highlight(diff_line)
      end

      def inline_diffs
        @inline_diffs ||= InlineDiff.for_lines(@raw_lines, project: project)
      end
    end
  end
end
