# frozen_string_literal: true

module Resolvers
  module IncidentManagement
    class OncallRotationsResolver < BaseResolver
      alias_method :schedule, :object

      type Types::IncidentManagement::OncallRotationType.connection_type, null: true

      when_single do
        argument :id,
                 ::Types::GlobalIDType[::IncidentManagement::OncallRotation],
                 required: true,
                 description: 'ID of the on-call rotation.',
                 prepare: ->(id, ctx) { id.model_id }
      end

      def resolve(**args)
        ::IncidentManagement::OncallRotationsFinder.new(context[:current_user], schedule.project, schedule, args).execute
      end
    end
  end
end
