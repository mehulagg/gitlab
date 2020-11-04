# frozen_string_literal: true

module Types
  class ReleaseLinksType < BaseObject
    graphql_name 'ReleaseLinks'

    authorize :download_code

    alias_method :release, :object

    present_using ReleasePresenter

    field :self_url, GraphQL::STRING_TYPE, null: true,
          description: 'HTTP URL of the release'
    field :edit_url, GraphQL::STRING_TYPE, null: true,
          description: "HTTP URL of the release's edit page",
          authorize: :update_release
    field :opened_merge_requests_url, GraphQL::STRING_TYPE, null: true,
          description: 'HTTP URL of the merge request page, filtered by this release and `state=open`'
    field :merged_merge_requests_url, GraphQL::STRING_TYPE, null: true,
          description: 'HTTP URL of the merge request page , filtered by this release and `state=merged`'
    field :closed_merge_requests_url, GraphQL::STRING_TYPE, null: true,
          description: 'HTTP URL of the merge request page , filtered by this release and `state=closed`'
    field :opened_issues_url, GraphQL::STRING_TYPE, null: true,
          description: 'HTTP URL of the issues page, filtered by this release and `state=open`'
    field :closed_issues_url, GraphQL::STRING_TYPE, null: true,
          description: 'HTTP URL of the issues page, filtered by this release and `state=closed`'

    field :merge_requests_url, GraphQL::STRING_TYPE, null: true, method: :opened_merge_requests_url,
          description: 'HTTP URL of the merge request page filtered by this release',
          deprecated: { reason: 'Use `openedMergeRequestsUrl`', milestone: '13.6' }
    field :issues_url, GraphQL::STRING_TYPE, null: true, method: :opened_issues_url,
          description: 'HTTP URL of the issues page filtered by this release',
          deprecated: { reason: 'Use `openedIssuesUrl`', milestone: '13.6' }
  end
end
