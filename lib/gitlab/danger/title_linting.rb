# frozen_string_literal: true

module Gitlab
  module Danger
    module TitleLinting
      DRAFT_REGEX = /\A*#{Regexp.union(/(?i)(\[WIP\]\s*|WIP:\s*|WIP$)/, /(?i)(\[draft\]|\(draft\)|draft:|draft\s\-\s|draft$)/)}+\s*/i.freeze

      def sanitize_mr_title(title)
        sanitize_not_ready_syntax(title).gsub(/`/, '\\\`')
      end

      def sanitize_not_ready_syntax(title)
        title.gsub(DRAFT_REGEX, '')
      end

      def draft_title?(title)
        DRAFT_REGEX.match?(title)
      end
    end
  end
end
