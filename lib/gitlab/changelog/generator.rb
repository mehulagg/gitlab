# frozen_string_literal: true

module Gitlab
  module Changelog
    # Parsing and generating of Markdown changelogs.
    class Generator
      # The regex used to parse a release header.
      RELEASE_REGEX =
        /^##\s+(?<version>#{Gitlab::Regex.unbounded_semver_regex})/.freeze

      def initialize(config, input)
        @config = config
        @lines = input.lines
        @locations = {}

        @lines.each_with_index do |line, index|
          matches = line.match(RELEASE_REGEX)

          next if !matches || !matches[:version]

          @locations[matches[:version]] = index
        end
      end

      def add(release)
        versions = [release.version, *@locations.keys]

        VersionSorter.rsort!(versions)

        new_index = versions.index(release.version)
        new_lines = @lines.dup
        markdown = release.to_markdown(@config)

        if (insert_after = versions[new_index + 1] || versions.first)
          line_index = @locations[insert_after]

          new_lines.insert(line_index, markdown)
        else
          new_lines.push(markdown)
        end

        new_lines.join('')
      end
    end
  end
end
