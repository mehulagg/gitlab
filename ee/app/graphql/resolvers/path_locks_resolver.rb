# frozen_string_literal: true

module Resolvers
  class PathLocksResolver < BaseResolver
    include Gitlab::Graphql::Authorize::AuthorizeResource
    include LooksAhead

    authorize :download_code

    argument :paths, [GraphQL::STRING_TYPE],
             required: false,
             description: 'List of paths to check for locks.'

    argument :exact, GraphQL::BOOLEAN_TYPE,
             required: false,
             default_value: true,
             description: 'Whether to return only exact matches for this path.'

    type Types::PathLockType, null: true

    alias_method :project, :object

    def resolve_with_lookahead(**args)
      authorize!(project)

      return [] unless path_lock_feature_enabled?

      find_path_locks(args)
    end

    private

    def preloads
      { user: [:user] }
    end

    def find_path_locks(args)
      # FIXME: make Gitlab::PathLocksFinder suited for this task
      # rubocop:disable CodeReuse/ActiveRecord
      locks = PathLock.where(project_id: project.id)
      locks = locks.where(path: args[:paths]) if args[:paths].present?
      # rubocop:enable CodeReuse/ActiveRecord

      apply_lookahead(locks)
    end

    def path_lock_feature_enabled?
      project.licensed_feature_available?(:file_locks)
    end
  end
end
