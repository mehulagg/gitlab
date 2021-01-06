# frozen_string_literal: true

module Types
  class EpicStateEventEnum < BaseEnum
    graphql_name 'EpicStateEvent'
    description 'State event of an epic'

    value 'REOPEN', value: 'reopen', description: 'Reopen the epic'
    value 'CLOSE', value: 'close', description: 'Close the epic'
  end
end
