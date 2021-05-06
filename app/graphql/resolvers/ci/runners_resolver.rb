# frozen_string_literal: true

module Resolvers
  module Ci
    class RunnersResolver < BaseResolver
      type Types::Ci::RunnerType, null: true

      def resolve(**args)
        ::Ci::RunnersFinder
          .new(current_user: current_user, params: {})
          .execute
      end
    end
  end
end
