# frozen_string_literal: true

module Types
  class IterationStateEnum < BaseEnum
    graphql_name 'IterationState'
    description 'State of a GitLab iteration'

    value 'upcoming'
    value 'started', deprecated: {
      reason: "Use current instead",
      milestone: '14.1'
    }
    value 'current'
    value 'opened'
    value 'closed'
    value 'all'
  end
end
