# frozen_string_literal: true

module Types
  class EpicStateEnum < BaseEnum
    graphql_name 'EpicState'
    description 'State of an epic'

    value 'all', description: 'All epics.'
    value 'opened', description: 'Open epics.'
    value 'closed', description: 'Closed epics.'
  end
end
