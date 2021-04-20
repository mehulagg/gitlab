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
        response(id)
      end

      private

      def response(id)
        @runner = ::Ci::Runner.find(id)

        {
          id: @runner.id,
          name: @runner.name,
          description: @runner.description,
          contacted_at: @runner.contacted_at,
          active: @runner.active,
          version: @runner.version,
          short_sha: @runner.short_sha,
          locked: @runner.locked,
          # tagList: @runner.tag_list,
          ip_address: @runner.ip_address,
          runner_type: @runner.runner_type
        }
      end
    end
  end
end
