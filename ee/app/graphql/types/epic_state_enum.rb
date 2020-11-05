# frozen_string_literal: true

module Types
  class EpicStateEnum < BaseEnum
    graphql_name 'EpicState'
    description 'State of an epic'

    value 'all'
    value 'opened'
    value 'closed'
  end
end
