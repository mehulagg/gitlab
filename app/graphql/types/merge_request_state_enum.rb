# frozen_string_literal: true

module Types
  class MergeRequestStateEnum < IssuableStateEnum
    graphql_name 'MergeRequestState'
    description 'State of a GitLab merge request'

    value 'all', 'Merge Request is in any state'
    value 'closed', 'Merge Request is closed, not merged'
    value 'locked', 'Merge Request that has its discussion locked'
    value 'merged', 'Merge Request has been merged'
    value 'opened', 'Merge Request is open'
  end
end
