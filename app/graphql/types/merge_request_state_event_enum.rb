# frozen_string_literal: true

module Types
  class MergeRequestStateEventEnum < BaseEnum
    graphql_name 'MergeRequestStateEvent'
    description 'Action to perform on a Merge Request'

    value 'OPEN',
      value: 'reopen',
      description: 'Open the merge request if it is closed.'

    value 'CLOSE',
      value: 'close',
      description: 'Close the merge request if it is open.'
  end
end
