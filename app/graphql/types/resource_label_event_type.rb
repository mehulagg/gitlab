# frozen_string_literal: true

module Types
  class ResourceLabelEventType < BaseObject
    graphql_name 'LabelEvent'
    authorize :read_resource_label_event

    field :label,
          type: Types::LabelType,
          null: false,
          description: 'The label this event describes.'

    field :issuable,
          type: ::Types::IssuableType,
          null: false,
          description: 'The resource the label was added to or removed from.'

    field :action,
          type: ::Types::ResourceLabelEventActionEnum,
          null: false,
          description: 'What happened to the label.'

    field :created_at,
          type: ::Types::TimeType,
          null: false,
          method: :created_at,
          description: 'When the action happened.'

    field :user,
          type: ::Types::UserType,
          null: true,
          description: 'The user that caused this event.'
  end
end
