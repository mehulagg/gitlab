# frozen_string_literal: true

module Resolvers
  class IterationsResolver < BaseResolver
    include Gitlab::Graphql::Authorize::AuthorizeResource
    include TimeFrameArguments

    argument :state, Types::IterationStateEnum,
             required: false,
             description: 'Filter iterations by state.'
    argument :title, GraphQL::STRING_TYPE,
             required: false,
             description: 'Fuzzy search by title.'

    # rubocop:disable Graphql/IDType
    argument :id, GraphQL::ID_TYPE,
             required: false,
             description: 'Global ID of the Iteration to look up.'
    # rubocop:enable Graphql/IDType

    argument :iid, GraphQL::ID_TYPE,
             required: false,
             description: 'Internal ID of the Iteration to look up.'
    argument :include_ancestors, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'Whether to include ancestor iterations. Defaults to true.'

    argument :iterations_cadence_id, ::Types::GlobalIDType[::Iterations::Cadence],
              required: false,
              description: 'Global ID of the Iteration Cadence by which to look up the Iterations.'

    type Types::IterationType.connection_type, null: true

    def resolve(**args)
      validate_timeframe_params!(args)

      authorize!

      args[:id] = id_from_args(args, :id, ::Iteration)
      args[:iterations_cadence_id] = id_from_args(args, :iterations_cadence_id, ::Iterations::Cadence)
      args[:include_ancestors] = true if args[:include_ancestors].nil? && args[:iid].nil?

      iterations = IterationsFinder.new(context[:current_user], iterations_finder_params(args)).execute

      # Necessary for scopedPath computation in IterationPresenter
      context[:parent_object] = parent

      offset_pagination(iterations)
    end

    private

    def iterations_finder_params(args)
      IterationsFinder.params_for_parent(parent, include_ancestors: args[:include_ancestors]).merge!(
        id: args[:id],
        iid: args[:iid],
        iterations_cadence_id: args[:iterations_cadence_id],
        state: args[:state] || 'all',
        start_date: args[:start_date],
        end_date: args[:end_date],
        search_title: args[:title]
      )
    end

    def parent
      @parent ||= object.respond_to?(:sync) ? object.sync : object
    end

    def authorize!
      Ability.allowed?(context[:current_user], :read_iteration, parent) || raise_resource_not_available_error!
    end

    # Originally accepted a raw model id. Now accept a gid, but allow a raw id
    # for backward compatibility
    def id_from_args(args, param, expected_type)
      return unless args[param].present?

      GitlabSchema.parse_gid(args[param], expected_type: expected_type).model_id
    rescue Gitlab::Graphql::Errors::ArgumentError
      args[param]
    end
  end
end
