# frozen_string_literal: true

require 'yaml'

module Tooling
  module Danger
    module FeatureFlag
      CREATE_CHANGELOG_COMMAND = 'bin/changelog -m %<mr_iid>s "%<mr_title>s"'
      CREATE_EE_CHANGELOG_COMMAND = 'bin/changelog --ee -m %<mr_iid>s "%<mr_title>s"'

      OPTIONAL_CHANGELOG_MESSAGE = <<~MSG
      If you want to create a changelog entry for GitLab FOSS, run the following:

          #{CREATE_CHANGELOG_COMMAND}

      If you want to create a changelog entry for GitLab EE, run the following instead:

          #{CREATE_EE_CHANGELOG_COMMAND}

      If this merge request [doesn't need a CHANGELOG entry](https://docs.gitlab.com/ee/development/changelog.html#what-warrants-a-changelog-entry), feel free to ignore this message.
      MSG

      REQUIRED_CHANGELOG_MESSAGE = <<~MSG
      To create a changelog entry, run the following:

          #{CREATE_CHANGELOG_COMMAND}

      This merge request requires a changelog entry because it [introduces a database migration](https://docs.gitlab.com/ee/development/changelog.html#what-warrants-a-changelog-entry).
      MSG

      def found
        @found ||= git.added_files.find { |path| path =~ %r{\A(ee/)?config/feature_flags/} }
      end

      def required_text
        CHANGELOG_MISSING_URL_TEXT +
          format(REQUIRED_CHANGELOG_MESSAGE, mr_iid: mr_iid, mr_title: sanitized_mr_title)
      end

      def optional_text
        CHANGELOG_MISSING_URL_TEXT +
          format(OPTIONAL_CHANGELOG_MESSAGE, mr_iid: mr_iid, mr_title: sanitized_mr_title)
      end

      private

      def mr_iid
        gitlab.mr_json["iid"]
      end

      def sanitized_mr_title
        TitleLinting.sanitize_mr_title(gitlab.mr_json["title"])
      end

      def categories_need_changelog?
        (helper.changes_by_category.keys - NO_CHANGELOG_CATEGORIES).any?
      end

      def without_no_changelog_label?
        (gitlab.mr_labels & NO_CHANGELOG_LABELS).empty?
      end

      class Found
        attr_reader :path

        def initialize(path)
          @path = path
        end

        def raw
          @raw ||= File.read(path)
        end

        def group
          @group ||= yaml['group']
        end

        def group_match_mr_label?(mr_group_label)
          mr_group_label == group
        end

        private

        def yaml
          @yaml ||= YAML.safe_load(raw)
        end
      end
    end
  end
end
