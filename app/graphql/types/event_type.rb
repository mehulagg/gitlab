# frozen_string_literal: true

module Types
  class EventType < BaseObject
    graphql_name 'Event'
    description 'Representing an event.'

    present_using EventPresenter

    authorize :read_event

    field :id, GraphQL::ID_TYPE,
          description: 'ID of the event.',
          null: false

    field :project, Types::ProjectType,
          description: 'The project this event is associated with.',
          null: true,
          authorize: :read_project

    field :group, Types::GroupType,
          description: 'Group this event is associated with.',
          null: true,
          authorize: :read_group

    field :author, Types::UserType,
          description: 'The author of this event.',
          null: false

    field :target_type, Types::EventTargetTypeEnum,
          description: 'Target type of the event.',
          null: true

    field :action, Types::EventActionEnum,
          description: 'Action of the event.',
          null: false

    field :created_at, Types::TimeType,
          description: 'Timestamp this event was created.',
          null: false

    field :updated_at, Types::TimeType,
          description: 'Timestamp this event was updated.',
          null: false

    def project
      Gitlab::Graphql::Loaders::BatchModelLoader.new(Project, object.project_id).find
    end

    def group
      Gitlab::Graphql::Loaders::BatchModelLoader.new(Group, object.group_id).find
    end

    def author
      Gitlab::Graphql::Loaders::BatchModelLoader.new(User, object.author_id).find
    end
  end
end
