# frozen_string_literal: true

module Resolvers
  module IncidentManagement
    class OncallShiftsResolver < BaseResolver
      alias_method :rotation, :synchronized_object

      type Types::IncidentManagement::OncallShiftType.connection_type, null: true

      argument :start_time,
               ::Types::TimeType,
               required: true,
               description: 'Start of timeframe to include shifts for.'

      argument :end_time,
               ::Types::TimeType,
               required: true,
               description: 'End of timeframe to include shifts for. Cannot exceed one month after start.'

      def resolve(start_time:, end_time:)
        result = ::IncidentManagement::OncallShifts::ReadService.new(
          rotation,
          current_user,
          start_time: start_time,
          end_time: end_time
        ).execute

        raise Gitlab::Graphql::Errors::ResourceNotAvailable, result.errors.join(', ') if result.error?

        result.payload[:shifts]
      end
    end
  end
end
