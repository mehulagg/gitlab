# frozen_string_literal: true

module Resolvers
  module Ci
    class RunnersResolver < BaseResolver
      type Types::Ci::RunnerType, null: true

      argument :ids, [GraphQL::ID_TYPE],
               required: false,
               description: 'Filter runners by IDs.'

      argument :status, ::Types::Ci::RunnerStatusEnum,
               required: false,
               description: 'Filter runners by status.'

      argument :tag_list, [GraphQL::STRING_TYPE],
               required: false,
               description: 'Filter by tags associated with the runner.'

      argument :sort, GraphQL::STRING_TYPE,
               required: false,
               description: 'Sort order of results.'

      def resolve(**args)
        ::Ci::RunnersFinder
          .new(current_user: current_user, params: runner_finder_params(args))
          .execute
      end

      private

      def runner_finder_params(params)
        {
          status_status: params[:status].to_s,
          tag_name: params[:tag_list],
          search: params[:search],
          sort: params[:sort]
        }.compact
      end

      def parse_gids(gids)
        gids&.map { |gid| GitlabSchema.parse_gid(gid, expected_type: ::Ci::Runner).model_id }
      end
    end
  end
end
