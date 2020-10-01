# frozen_string_literal: true

module Types
  class IssuableStateEventEnum
    graphql_name 'IssuableStateEvent'
    description 'Values for issuable state events'

    value 'REOPEN', 'Reopens the issuable', value: 'reopen'
    value 'CLOSE', 'Closes the issuable', value: 'close'
  end
end
