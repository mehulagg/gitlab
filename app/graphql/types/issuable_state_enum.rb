# frozen_string_literal: true

module Types
  class IssuableStateEnum < BaseEnum
    graphql_name 'IssuableState'
    description 'State of a GitLab issue or merge request'

    value 'OPENED', description: "In open state", value: 'opened'
    value 'CLOSED', description: "In closed state", value: 'closed'
    value 'LOCKED', description: "Discussion has been locked", value: 'locked'
    value 'ALL', description: 'All available', value: 'all'
  end
end
