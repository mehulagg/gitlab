# frozen_string_literal: true

module EE
  module Mutations
    module Boards
      module ScopedBoardArguments
        extend ActiveSupport::Concern

        included do
          argument :assignee_id,
                   ::Types::GlobalIDType[::User],
                   required: false,
                   loads: ::Types::UserType,
                   description: 'The ID of user to be assigned to the board.'

          # Cannot pre-load ::Types::MilestoneType because we are also assigning values like:
          # ::Timebox::None(0), ::Timebox::Upcoming(-2) or ::Timebox::Started(-3), that cannot be resolved to a DB record.
          argument :milestone_id,
                   ::Types::GlobalIDType[::Milestone],
                   required: false,
                   description: 'The ID of milestone to be assigned to the board.'

          # Cannot pre-load ::Types::IterationType because we are also assigning values like:
          # ::Iteration::Predefined::None(0) or ::Iteration::Predefined::Current(-4), that cannot be resolved to a DB record.
          argument :iteration_id,
                   ::Types::GlobalIDType[::Iteration],
                   required: false,
                   description: 'The ID of iteration to be assigned to the board.'

          argument :weight,
                   GraphQL::INT_TYPE,
                   required: false,
                   description: 'The weight value to be assigned to the board.'

          argument :labels, [GraphQL::STRING_TYPE],
                   required: false,
                   description: copy_field_description(Types::IssueType, :labels)

          argument :label_ids, [::Types::GlobalIDType[::Label]],
                   required: false,
                   description: 'The IDs of labels to be added to the board.'
        end
      end
    end
  end
end
