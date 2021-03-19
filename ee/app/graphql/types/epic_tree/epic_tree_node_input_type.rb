# frozen_string_literal: true

module Types
  module EpicTree
    class EpicTreeNodeInputType < BaseInputObject
      graphql_name 'EpicTreeNodeFieldsInputType'
      description 'A node of an epic tree.'

      argument :id,
               ::Types::GlobalIDType[::EpicTreeSorting],
               required: true,
               description: 'The ID of the epic_issue or epic that is being moved.'

      argument :adjacent_reference_id,
               ::Types::GlobalIDType[::EpicTreeSorting],
               required: false,
               description: 'The ID of the epic_issue or issue that the actual epic or issue is switched with.'

      argument :relative_position,
               MoveTypeEnum,
               required: false,
               description: 'The type of the switch, after or before allowed.'

      argument :new_parent_id,
               ::Types::GlobalIDType[::Epic],
               required: false,
               description: 'ID of the new parent epic.'
    end
  end
end
