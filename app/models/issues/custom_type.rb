# frozen_string_literal: true

# Note: initial thinking behind `icon_name` is for it to do triple duty:
# 1. one of our svg icon names, such as `external-link` or a new one `bug`
# 2. if it's an absolute url, then url to a user uploaded icon/image
# 3. an emoji, with the format of `:smile:`
module Issues
  class CustomType < ApplicationRecord
    self.table_name = 'issue_custom_types'

    include CacheMarkdownField
    include Sortable
    include FromUnion

    cache_markdown_field :description, pipeline: :single_line

    enum issue_type: Issue.issue_types

    belongs_to :group, foreign_key: :namespace_id, optional: true
    has_many :issues, foreign_key: :issue_custom_type_id, inverse_of: :issue_custom_type

    before_validation :strip_whitespace

    # Don't allow ',' for type names
    validates :name, presence: true, format: { with: /\A[^,]+\z/ }
    validates :name, uniqueness: { scope: [:namespace_id] }
    validates :name, length: { maximum: 255 }
    validates :icon_name, length: { maximum: 255 }

    def open_issues_count(user = nil)
      issues_count(user, state: 'opened')
    end

    def closed_issues_count(user = nil)
      issues_count(user, state: 'closed')
    end

    def name=(value)
      write_attribute(:name, sanitize_value(value)) if value.present?
    end

    def description=(value)
      write_attribute(:description, sanitize_value(value)) if value.present?
    end

    private

    def issues_count(user, params = {})
      params.merge!(issue_custom_type_ids: self.id, scope: 'all')
      params[:namespace_id] = group.id if group

      IssuesFinder.new(user, params.with_indifferent_access).execute.count
    end

    def sanitize_value(value)
      CGI.unescapeHTML(Sanitize.clean(value.to_s))
    end

    def strip_whitespace
      name&.strip!
    end

    def self.default_custom_issue
      Issues::CustomType.new(name: 'Issue', issue_type: 'issue', id: nil, icon_name: 'issue-type-issue')
    end

    def self.default_custom_incident
      Issues::CustomType.new(name: 'Incident', issue_type: 'incident', id: nil, icon_name: 'issue-type-incident')
    end

    def self.default_custom_test_case
      Issues::CustomType.new(name: 'Test Case', issue_type: 'test_case', id: nil, icon_name: 'documents')
    end
  end
end
