# frozen_string_literal: true

module Gitlab
  module Changelog
    # Configuration settings used when generating changelogs.
    class Config
      # When rendering changelog entries, authors are not included.
      AUTHORS_NONE = 'none'

      # The path to the configuration file as stored in the project's Git
      # repository.
      FILE_PATH = '.gitlab/changelog.yml'

      # The default date format to use for formatting release dates.
      DEFAULT_DATE_FORMAT = '%Y-%m-%d'

      # The maximum number of characters that may be included in the date
      # format.
      MAX_DATE_FORMAT_LENGTH = 64

      # The default template to use for generating release sections.
      DEFAULT_TEMPLATE = File.read(File.join(__dir__, 'template.tpl'))

      attr_accessor :date_format, :categories, :template

      def self.from_git(project)
        if (yaml = project.repository.changelog_yml_content)
          from_hash(project, YAML.safe_load(yaml))
        else
          new(project)
        end
      end

      def self.from_hash(project, hash)
        config = new(project)

        # We apply a limit to the format size so users can't supply infinitely
        # long formatting strings. While this in theory should be fine, it may
        # at some point slow down the date formatting unexpectedly; so it's
        # better to be safe than sorry.
        if (date = hash['date_format']) && date.length <= MAX_DATE_FORMAT_LENGTH
          config.date_format = date
        end

        if (template = hash['template'])
          config.template = Template::Compiler.new.compile(template)
        end

        if hash['categories'].is_a?(Hash)
          config.categories = hash['categories']
        end

        config
      end

      def initialize(project)
        @project = project
        @date_format = DEFAULT_DATE_FORMAT
        @template = Template::Compiler.new.compile(DEFAULT_TEMPLATE)
        @categories = {}
      end

      def contributor?(user)
        @project.team.contributor?(user)
      end

      def category(name)
        @categories[name] || name
      end

      def format_date(date)
        date.strftime(@date_format)
      end
    end
  end
end
