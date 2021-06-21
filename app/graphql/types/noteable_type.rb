# frozen_string_literal: true

module Types
  class NoteableType < BaseUnion
    graphql_name 'Noteable'
    description 'Represents an object that supports notes.'

    possible_types Types::IssueType, Types::DesignManagement::DesignType

    def self.resolve_type(object, context)
      case object
      when Issue
        Types::IssueType
      when ::DesignManagement::Design
        Types::DesignManagement::DesignType
      else
        raise 'Unsupported issuable type'
      end
    end
  end
end
