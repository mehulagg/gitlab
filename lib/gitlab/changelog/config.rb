# frozen_string_literal: true

module Gitlab
  module Changelog
    # Configuration settings used when generating changelogs.
    class Config
      # When rendering changelog entries, authors are not included.
      AUTHORS_NONE = 'none'

      # The path to the configuration file as stored in the project's Git
      # repository.
      FILE_PATH = '.gitlab/changelog_config.yml'

      # The default date format to use for formatting release dates.
      DEFAULT_DATE_FORMAT = '%Y-%m-%d'

      # The default template to use for generating release sections.
      DEFAULT_TEMPLATE = File.read(File.join(__dir__, 'template.tpl'))

      attr_accessor :date_format, :categories, :template

      def self.from_git(project)
        if (yaml = project.repository.changelog_config)
          from_hash(project, YAML.safe_load(yaml))
        else
          new(project)
        end
      end

      def self.from_hash(project, hash)
        config = new(project)

        if (date = hash['date_format'])
          config.date_format = date
        end

        if (template = hash['template'])
          config.template = Parser.new.parse_and_transform(template)
        end

        if (categories = hash['categories'])
          if categories.is_a?(Hash)
            config.categories = categories
          else
            raise Error, 'The "categories" configuration key must be a Hash'
          end
        end

        config
      end

      def initialize(project)
        @project = project
        @date_format = DEFAULT_DATE_FORMAT
        @template = Parser.new.parse_and_transform(DEFAULT_TEMPLATE)
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
