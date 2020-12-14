# frozen_string_literal: true

module Resolvers
  module IncidentManagement
    class OncallShiftResolver < BaseResolver
      alias_method :rotation, :synchronized_object

      type Types::IncidentManagement::OncallShiftType.connection_type, null: true

      argument :starts_at,
               ::Types::TimeType,
               required: true,
               description: 'Start of timeframe.'

      argument :ends_at,
               ::Types::TimeType,
               required: true,
               description: 'End of timeframe.'

      def resolve(starts_at:, ends_at:)
        ::IncidentManagement::OncallShiftGenerator.new(rotation, starts_at: starts_at, ends_at: ends_at).execute
      end
    end
  end
end
