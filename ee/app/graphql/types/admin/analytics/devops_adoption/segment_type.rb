# frozen_string_literal: true
# rubocop:disable Graphql/AuthorizeTypes

module Types
  module Admin
    module Analytics
      module DevopsAdoption
        class SegmentType < BaseObject
          graphql_name 'DevopsAdoptionSegment'
          description 'Segment'

          field :id, GraphQL::ID_TYPE, null: false,
                description: "ID of the segment"

          field :name, GraphQL::STRING_TYPE, null: false,
            description: 'Name of the segment'

          field :groups, Types::GroupType.connection_type, null: true,
                description: 'Assigned groups'
        end
      end
    end
  end
end
