# frozen_string_literal: true

module Resolvers
  module Ci
    class GroupRunnersResolver < RunnersResolver
      type Types::Ci::RunnerType.connection_type, null: true

      argument :membership, ::Types::Ci::RunnerMembershipFilterEnum,
               required: false,
               description: 'Control which runners to include in the results.'

      protected

      def runners_finder_params(params)
        super(params).merge(membership: params[:membership])
      end
    end
  end
end
