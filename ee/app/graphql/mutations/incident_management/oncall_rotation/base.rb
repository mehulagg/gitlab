# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module OncallRotation
      class Base < BaseMutation
        field :oncall_rotation,
              ::Types::IncidentManagement::OncallRotationType,
              null: true,
              description: 'The on-call rotation'

        authorize :admin_incident_management_oncall_schedule

        private

        def response(result)
          {
            oncall_rotation: result.payload[:oncall_rotation],
            errors: result.errors
          }
        end
      end
    end
  end
end
