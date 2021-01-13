# frozen_string_literal: true

module Resolvers
  class EpicsResolver < BaseResolver
    include TimeFrameArguments
    include LooksAhead

    argument :iid, GraphQL::ID_TYPE,
             required: false,
             description: 'IID of the epic, e.g., "1"'

    argument :iids, [GraphQL::ID_TYPE],
             required: false,
             description: 'List of IIDs of epics, e.g., [1, 2]'

    argument :state, Types::EpicStateEnum,
             required: false,
             description: 'Filter epics by state'

    argument :search, GraphQL::STRING_TYPE,
             required: false,
             description: 'Search query for epic title or description'

    argument :sort, Types::EpicSortEnum,
             required: false,
             description: 'List epics by sort order'

    argument :author_username, GraphQL::STRING_TYPE,
             required: false,
             description: 'Filter epics by author'

    argument :label_name, [GraphQL::STRING_TYPE],
             required: false,
             description: 'Filter epics by labels'

    argument :milestone_title, GraphQL::STRING_TYPE,
             required: false,
             description: "Filter epics by milestone title, computed from epic's issues"

    argument :iid_starts_with, GraphQL::STRING_TYPE,
             required: false,
             description: 'Filter epics by IID for autocomplete'

    argument :include_descendant_groups, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'Include epics from descendant groups',
             default_value: true

    argument :confidential, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'Filter epics by given confidentiality'

    type Types::EpicType, null: true

    def ready?(**args)
      validate_timeframe_params!(args)
      validate_starts_with_iid!(args)

      super(**args)
    end

    def resolve_with_lookahead(**args)
      @resolver_object = object.respond_to?(:sync) ? object.sync : object

      return [] unless resolver_object.present?
      return [] unless epic_feature_enabled?

      find_epics(transform_args(args))
    end

    private

    attr_reader :resolver_object

    def unconditional_includes
      [:group]
    end

    def preloads
      {
        parent: [:parent]
      }
    end

    def find_epics(args)
      apply_lookahead(EpicsFinder.new(context[:current_user], args).execute)
    end

    def epic_feature_enabled?
      group.feature_available?(:epics)
    end

    def transform_args(args)
      transformed               = args.dup
      transformed[:group_id]    = group
      transformed[:parent_id]   = parent.id if parent
      transformed[:iids]      ||= [args[:iid]].compact

      transformed
    end

    # `resolver_object` refers to the object we're currently querying on, and is usually a `Group`
    # when querying an Epic.  In the case of field that uses this resolver, for example
    # an Epic's `children` field, then `resolver_object` is an `EpicPresenter` (rather than an Epic).
    # But that's the epic we need in order to scope the find to only children of this epic,
    # using the `parent_id`
    def parent
      resolver_object if resolver_object.is_a?(Epic)
    end

    def group
      return resolver_object if resolver_object.is_a?(Group)

      parent.group
    end

    # If we're querying for multiple iids and selecting issues, then ideally
    # we want to batch the epic and issue queries into one to reduce N+1 and memory.
    # https://gitlab.com/gitlab-org/gitlab/issues/11841
    # Until we do that, add in child_complexity for each iid requested
    # (minus one for the automatically added child_complexity in the BaseField)
    def self.resolver_complexity(args, child_complexity:)
      complexity  = super
      complexity += (args[:iids].count - 1) * child_complexity if args[:iids]

      complexity
    end

    # https://gitlab.com/gitlab-org/gitlab/issues/205312
    def self.complexity_multiplier(args)
      0.001
    end

    def validate_starts_with_iid!(args)
      return unless args[:iid_starts_with].present?

      unless EpicsFinder.valid_iid_query?(args[:iid_starts_with])
        raise Gitlab::Graphql::Errors::ArgumentError, 'Invalid `iidStartsWith` query'
      end
    end
  end
end
