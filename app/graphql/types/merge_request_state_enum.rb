# frozen_string_literal: true

module Types
  class MergeRequestStateEnum < IssuableStateEnum
    graphql_name 'MergeRequestState'
    description 'State of a GitLab merge request'

    value 'ALL', description: 'Merge Request is in any state', value: 'all'
    value 'CLOSED', description: 'Merge Request is closed, not merged', value: 'closed'
    value 'LOCKED', description: 'Merge Request that has its discussion locked', value: 'locked'
    value 'MERGED', description: 'Merge Request has been merged', value: 'merged'
    value 'OPENED', description: 'Merge Request is open', value: 'opened'
  end
end
