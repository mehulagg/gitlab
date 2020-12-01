# frozen_string_literal: true

module EE
  module Types
    module BoardType
      extend ActiveSupport::Concern

      prepended do
        field :assignee, type: ::Types::UserType, null: true,
              description: 'The board assignee.'

        field :epics, ::Types::Boards::BoardEpicType.connection_type, null: true,
              description: 'Epics associated with board issues.',
              resolver: ::Resolvers::BoardGroupings::EpicsResolver,
              complexity: 5

        field :hide_backlog_list, type: GraphQL::BOOLEAN_TYPE, null: true,
              description: 'Whether or not backlog list is hidden.'

        field :hide_closed_list, type: GraphQL::BOOLEAN_TYPE, null: true,
              description: 'Whether or not closed list is hidden.'

        field :labels, ::Types::LabelType.connection_type, null: true,
              description: 'Labels of the board'

        field :milestone, type: ::Types::MilestoneType, null: true,
              description: 'The board milestone.'

        field :weight, type: GraphQL::INT_TYPE, null: true,
              description: 'Weight of the board.'
      end
    end
  end
end
