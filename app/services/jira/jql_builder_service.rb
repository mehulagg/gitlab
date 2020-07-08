# frozen_string_literal: true

module Jira
  class JqlBuilderService
    DEFAULT_SORT = 'created'
    DEFAULT_SORT_DIRECTION = 'DESC'

    # https://confluence.atlassian.com/jirasoftwareserver082/search-syntax-for-text-fields-974359692.html
    JQL_SPECIAL_CHARS = %w[" + . , ; ? | * / % ^ $ # @ [ ] \\].freeze

    def initialize(jira_project_key, params = {})
      @jira_project_key = jira_project_key
      @search = params[:search]
      @labels = params[:labels]
      @sort = params[:sort] || DEFAULT_SORT
      @sort_direction = params[:sort_direction] || DEFAULT_SORT_DIRECTION
    end

    def execute
      [
        jql_filters,
        order_by
      ].join(' ')
    end

    private

    attr_reader :jira_project_key, :sort, :sort_direction, :search, :labels

    def jql_filters
      [
        by_project,
        by_labels,
        by_summary_and_description
      ].compact.join(' AND ')
    end

    def by_summary_and_description
      return if search.blank?

      escaped_search = remove_special_chars(search)
      %Q[(summary ~ "#{escaped_search}" OR description ~ "#{escaped_search}")]
    end

    def by_project
      "project = #{jira_project_key}"
    end

    def by_labels
      return if labels.blank?

      labels.map { |label| %Q[labels = "#{escape_quotes(label)}"] }.join(' AND ')
    end

    def order_by
      "order by #{sort} #{sort_direction}"
    end

    def escape_quotes(param)
      param.gsub('\\', '\\\\\\').gsub('"', '\\"')
    end

    def remove_special_chars(param)
      param.delete(JQL_SPECIAL_CHARS.join).downcase.squish
    end
  end
end
