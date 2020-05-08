# frozen_string_literal: true

class ResourceMilestoneEvent < ResourceEvent
  include IgnorableColumns
  include IssueResourceEvent
  include MergeRequestResourceEvent

  belongs_to :milestone

  validate :exactly_one_issuable

  enum action: {
    add: 1,
    remove: 2
  }

  # state is used for issue and merge request states.
  enum state: Issue.available_states.merge(MergeRequest.available_states)

  ignore_columns %i[reference reference_html cached_markdown_version], remove_with: '13.1', remove_after: '2020-06-22'

  def self.issuable_attrs
    %i(issue merge_request).freeze
  end

  def milestone_title
    milestone&.title
  end
end
