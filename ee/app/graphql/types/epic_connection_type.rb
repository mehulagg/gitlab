# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class EpicConnectionType < IssuableConnectionType
    def issuable_model
      Epic
    end
  end
end
