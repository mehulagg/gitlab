# frozen_string_literal: true

module Types
  class EpicType < BaseObject
    include ::Gitlab::Graphql::Aggregations::Epics::Constants

    graphql_name 'Epic'
    description 'Represents an epic'
    accepts ::Epic
    authorize :read_epic

    expose_permissions Types::PermissionTypes::Epic

    present_using EpicPresenter

    implements(Types::Notes::NoteableType)
    implements(Types::CurrentUserTodos)

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID of the epic'
    field :iid, GraphQL::ID_TYPE, null: false,
          description: 'Internal ID of the epic'
    field :title, GraphQL::STRING_TYPE, null: true,
          description: 'Title of the epic'
    field :description, GraphQL::STRING_TYPE, null: true,
          description: 'Description of the epic'
    field :state, EpicStateEnum, null: false,
          description: 'State of the epic'
    field :confidential, GraphQL::BOOLEAN_TYPE, null: true,
          description: 'Indicates if the epic is confidential'

    field :group, GroupType, null: false,
          description: 'Group to which the epic belongs'
    field :parent, EpicType, null: true,
          description: 'Parent epic of the epic'
    field :author, Types::UserType, null: false,
          description: 'Author of the epic',
          resolve: -> (obj, _args, _ctx) { Gitlab::Graphql::Loaders::BatchModelLoader.new(User, obj.author_id).find }

    field :start_date, Types::TimeType, null: true,
          description: 'Start date of the epic'
    field :start_date_is_fixed, GraphQL::BOOLEAN_TYPE, null: true,
          description: 'Indicates if the start date has been manually set',
          method: :start_date_is_fixed?, authorize: :admin_epic
    field :start_date_fixed, Types::TimeType, null: true,
          description: 'Fixed start date of the epic',
          authorize: :admin_epic
    field :start_date_from_milestones, Types::TimeType, null: true,
          description: 'Inherited start date of the epic from milestones',
          authorize: :admin_epic

    field :due_date, Types::TimeType, null: true,
          description: 'Due date of the epic'
    field :due_date_is_fixed, GraphQL::BOOLEAN_TYPE, null: true,
          description: 'Indicates if the due date has been manually set',
          method: :due_date_is_fixed?, authorize: :admin_epic
    field :due_date_fixed, Types::TimeType, null: true,
          description: 'Fixed due date of the epic',
          authorize: :admin_epic
    field :due_date_from_milestones, Types::TimeType, null: true,
          description: 'Inherited due date of the epic from milestones',
          authorize: :admin_epic

    field :upvotes, GraphQL::INT_TYPE, null: false,
          description: 'Number of upvotes the epic has received'
    field :downvotes, GraphQL::INT_TYPE, null: false,
          description: 'Number of downvotes the epic has received'

    field :closed_at, Types::TimeType, null: true,
          description: 'Timestamp of when the epic was closed'
    field :created_at, Types::TimeType, null: true,
          description: 'Timestamp of when the epic was created'
    field :updated_at, Types::TimeType, null: true,
          description: 'Timestamp of when the epic was updated'

    field :children, ::Types::EpicType.connection_type, null: true,
          description: 'Children (sub-epics) of the epic',
          max_page_size: 2000,
          resolver: ::Resolvers::EpicsResolver
    field :labels, Types::LabelType.connection_type, null: true,
          description: 'Labels assigned to the epic'

    field :has_children, GraphQL::BOOLEAN_TYPE, null: false,
          description: 'Indicates if the epic has children'
    field :has_issues, GraphQL::BOOLEAN_TYPE, null: false,
          description: 'Indicates if the epic has direct issues'
    field :has_parent, GraphQL::BOOLEAN_TYPE, null: false,
          method: :has_parent?,
          description: 'Indicates if the epic has a parent epic'

    field :web_path, GraphQL::STRING_TYPE, null: false,
          description: 'Web path of the epic',
          method: :group_epic_path
    field :web_url, GraphQL::STRING_TYPE, null: false,
          description: 'Web URL of the epic',
          method: :group_epic_url

    field :relative_position, GraphQL::INT_TYPE, null: true,
          description: 'The relative position of the epic in the epic tree'
    field :relation_path, GraphQL::STRING_TYPE, null: true,
           description: 'URI path of the epic-issue relationship',
           method: :group_epic_link_path

    field :reference, GraphQL::STRING_TYPE, null: false,
    description: 'Internal reference of the epic. Returned in shortened format by default',
    method: :epic_reference do
      argument :full, GraphQL::BOOLEAN_TYPE, required: false, default_value: false,
                description: 'Indicates if the reference should be returned in full'
    end

    field :participants, Types::UserType.connection_type, null: true,
          description: 'List of participants for the epic',
          complexity: 5

    field :subscribed, GraphQL::BOOLEAN_TYPE,
      method: :subscribed?,
      null: false,
      complexity: 5,
      description: 'Indicates the currently logged in user is subscribed to the epic'

    field :issues,
          Types::EpicIssueType.connection_type,
          null: true,
          complexity: 5,
          description: 'A list of issues associated with the epic',
          max_page_size: 2000,
          resolver: Resolvers::EpicIssuesResolver

    field :descendant_counts, Types::EpicDescendantCountType, null: true,
      description: 'Number of open and closed descendant epics and issues',
      resolve: -> (epic, args, ctx) do
        Gitlab::Graphql::Aggregations::Epics::LazyEpicAggregate.new(ctx, epic.id, COUNT)
      end

    field :descendant_weight_sum, Types::EpicDescendantWeightSumType, null: true,
      description: "Total weight of open and closed issues in the epic and its descendants",
      resolve: -> (epic, args, ctx) do
        Gitlab::Graphql::Aggregations::Epics::LazyEpicAggregate.new(ctx, epic.id, WEIGHT_SUM)
      end

    field :health_status, Types::EpicHealthStatusType, null: true, complexity: 10,
      description: 'Current health status of the epic',
      resolve: -> (epic, args, ctx) do
        Epics::DescendantCountService.new(epic, ctx[:current_user])
      end

    def has_children?
      Gitlab::Graphql::Aggregations::Epics::LazyEpicAggregate.new(context, object.id, COUNT) do |node, _aggregate_object|
        node.children.any?
      end
    end

    def has_issues?
      Gitlab::Graphql::Aggregations::Epics::LazyEpicAggregate.new(context, object.id, COUNT) do |node, _aggregate_object|
        node.has_issues?
      end
    end

    alias_method :has_children, :has_children?
    alias_method :has_issues, :has_issues?
  end
end
