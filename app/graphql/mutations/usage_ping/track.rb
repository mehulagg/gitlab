# frozen_string_literal: true

module Mutations
  module UsagePing
    class Track < BaseMutation
      graphql_name 'TrackUsagePingEvent'

      argument :event, GraphQL::STRING_TYPE,
               required: true,
               description: "The event name that should be tracked"

      def resolve(event:)
        service = ::UsagePing::TrackService.new(container: event, current_user: current_user)
        result = service.execute

        if result.success?
          { errors: [] }
        else
          { errors: result.errors }
        end
      end
    end
  end
end
