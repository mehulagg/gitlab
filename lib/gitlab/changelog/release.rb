# frozen_string_literal: true

module Gitlab
  module Changelog
    # A release to add to a changelog.
    class Release
      attr_reader :version

      def initialize(version:, date:, entries:)
        @version = version
        @date = date
        @entries = entries
      end

      def to_markdown(config)
        lines = ["## #{@version} (#{config.format_date(@date)})"]

        @entries.each do |category, entries|
          amount = entries.length
          changes = amount == 1 ? '1 change' : "#{amount} changes"

          lines.push("\n### #{config.category(category)} (#{changes})\n")
          entries.each { |entry| lines.push(entry.to_markdown(config)) }
        end

        lines.push("\n")
        lines.join("\n")
      end
    end
  end
end
