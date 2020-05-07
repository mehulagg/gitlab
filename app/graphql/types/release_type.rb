# frozen_string_literal: true

module Types
  class ReleaseType < BaseObject
    graphql_name 'Release'

    authorize :read_release

    alias_method :release, :object

    present_using ReleasePresenter

    field :tag_name, GraphQL::STRING_TYPE, null: false, method: :tag,
          description: 'Name of the tag associated with the release'
    field :tag_path, GraphQL::STRING_TYPE, null: true,
          description: 'Relative web path to the tag associated with the release'
    field :description, GraphQL::STRING_TYPE, null: true,
          description: 'Description (also known as "release notes") of the release'
    markdown_field :description_html, null: true
    field :name, GraphQL::STRING_TYPE, null: true,
          description: 'Name of the release'
    field :evidence_sha, GraphQL::STRING_TYPE, null: true,
          description: "SHA of the release's evidence"
    field :created_at, Types::TimeType, null: true,
          description: 'Timestamp of when the release was created'
    field :released_at, Types::TimeType, null: true,
          description: 'Timestamp of when the release was released'
    field :milestones, Types::MilestoneType.connection_type, null: true,
          description: 'Milestones associated to the release'

    field :author, Types::UserType, null: true,
          description: 'User that created the release'

    def author
      Gitlab::Graphql::Loaders::BatchModelLoader.new(User, release.author_id).find
    end

    field :commit, Types::CommitType, null: true,
          complexity: 10, calls_gitaly: true,
          description: 'The commit associated with the release',
          authorize: :reporter_access

    def commit
      return if release.sha.nil?

      release.project.commit_by(oid: release.sha)
    end
  end
end
