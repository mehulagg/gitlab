# frozen_string_literal: true

module Types
  class MilestoneStateEnum < BaseEnum
    graphql_name 'MilestoneStateEnum'
    description 'Current state of milestone'

    value 'ACTIVE', description: 'Milestone is currently active', value: 'active'
    value 'CLOSED', description: 'Milestone is closed', value: 'closed'
  end
end
