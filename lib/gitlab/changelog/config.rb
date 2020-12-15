# frozen_string_literal: true

module Gitlab
  module Changelog
    # Class description
    class Config
      AUTHORS_NONE = 'none'
      AUTHORS_CONTRIBUTORS_ONLY = 'contributors'

      attr_reader :output, :categories

      def initialize(
        project:,
        date_format: '%Y-%m-%d',
        authors: AUTHORS_CONTRIBUTORS_ONLY,
        output: 'CHANGELOG.md',
        categories: {}
      )
        @project = project
        @date_format = date_format
        @authors = authors
        @output = output
        @project_members = nil
        @categories = categories
      end

      def show_author?(user)
        case @authors
        when AUTHORS_NONE
          false
        when AUTHORS_CONTRIBUTORS_ONLY
          @project.team.contributor?(user)
        else
          true
        end
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
