# frozen_string_literal: true

module Types
  class IterationStateEnum < BaseEnum
    graphql_name 'IterationState'
    description 'State of a GitLab iteration'

    value 'upcoming'
    value 'started'
    value 'opened'
    value 'closed'
    value 'all'
  end
end
