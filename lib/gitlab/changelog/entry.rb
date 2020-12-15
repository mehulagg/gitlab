# frozen_string_literal: true

module Gitlab
  module Changelog
    # A single changelog entry.
    class Entry
      def initialize(title:, commit:, author: nil, issue: nil, merge_request: nil)
        @title = title
        @commit = commit
        @author = author
        @issue = issue
        @merge_request = merge_request
      end

      def to_markdown(config)
        output = "- [#{@title}](#{@commit})"

        if (author = @author) && config.show_author?(author)
          output += " by #{author.to_reference(full: true)}"
        end

        links = []

        if (issue = @issue)
          links.push("[issue](#{issue.to_reference(full: true)})")
        end

        if (mr = @merge_request)
          links.push("[merge request](#{mr.to_reference(full: true)})")
        end

        if links.any?
          output += " (#{links.join(', ')})"
        end

        output
      end
    end
  end
end
