# frozen_string_literal: true

module Types
  class TimelogType < BaseObject
    graphql_name 'Timelog'

    authorize :read_group_timelogs

    field :spent_at,
          Types::TimeType,
          null: true,
          description: 'Timestamp of when the time tracked was spent at.'

    field :time_spent,
          GraphQL::INT_TYPE,
          null: false,
          description: 'The time spent displayed in seconds.'

    field :human_time_spent, GraphQL::STRING_TYPE, null: true,
          description: 'The time spent displayed in human-readable form instead of the number of seconds. For example, `1m` or `1h`.'

    field :user,
          Types::UserType,
          null: false,
          description: 'The user that logged the time.'

    field :issue,
          Types::IssueType,
          null: true,
          description: 'The issue that logged time was added to.'

    field :merge_request,
          Types::MergeRequestType,
          null: true,
          description: 'The merge request that logged time was added to.'

    field :note,
          Types::Notes::NoteType,
          null: true,
          description: 'The note where the quick action to add the logged time was executed.'

    def user
      Gitlab::Graphql::Loaders::BatchModelLoader.new(User, object.user_id).find
    end

    def issue
      Gitlab::Graphql::Loaders::BatchModelLoader.new(Issue, object.issue_id).find
    end
  end
end
