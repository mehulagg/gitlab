# frozen_string_literal: true

module Resolvers
  module Ci
    class RunnerResolver < BaseResolver
      type Types::Ci::RunnerType, null: true
      description 'Runner information.'

      argument :id,
               type: GraphQL::ID_TYPE,
               required: true,
               description: 'Runner ID.'

      def resolve(id:)
        ::Ci::Runner.find(id)
      end
    end
  end
end
