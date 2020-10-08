# frozen_string_literal: true

module Resolvers
  class IterationsResolver < BaseResolver
    include Gitlab::Graphql::Authorize::AuthorizeResource
    include TimeFrameArguments

    argument :state, Types::IterationStateEnum,
             required: false,
             description: 'Filter iterations by state'
    argument :title, GraphQL::STRING_TYPE,
             required: false,
             description: 'Fuzzy search by title'
    argument :id, GraphQL::ID_TYPE,
             required: false,
             description: 'The ID of the Iteration to look up'
    argument :iid, GraphQL::ID_TYPE,
             required: false,
             description: 'The internal ID of the Iteration to look up'
    argument :include_ancestors, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'Whether to include ancestor iterations. Defaults to true'

    type Types::IterationType, null: true

    def resolve(**args)
      validate_timeframe_params!(args)

      authorize!

      args[:include_ancestors] = true if args[:include_ancestors].nil? && args[:iid].nil?

      iterations = IterationsFinder.new(context[:current_user], iterations_finder_params(args)).execute

      # Necessary for scopedPath computation in IterationPresenter
      context[:parent_object] = parent

      Gitlab::Graphql::Pagination::OffsetActiveRecordRelationConnection.new(iterations)
    end

    private

    def iterations_finder_params(args)
      {
        id: args[:id],
        iid: args[:iid],
        state: args[:state] || 'all',
        start_date: args[:start_date],
        end_date: args[:end_date],
        search_title: args[:title]
      }.merge(IterationsFinder.params_for_parent(include_ancestors: args[:include_ancestors]))
    end

    def parent
      @parent ||= object.respond_to?(:sync) ? object.sync : object
    end

    def authorize!
      Ability.allowed?(context[:current_user], :read_iteration, parent) || raise_resource_not_available_error!
    end
  end
end
