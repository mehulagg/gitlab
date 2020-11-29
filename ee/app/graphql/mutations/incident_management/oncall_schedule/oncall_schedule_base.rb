# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module OncallSchedule
      class OncallScheduleBase < BaseMutation
        field :oncall_schedule,
              ::Types::IncidentManagement::OncallScheduleType,
              null: true,
              description: 'The on-call schedule'

        authorize :admin_incident_management_oncall_schedule

        private

        def response(result)
          {
            oncall_schedule: result.payload[:oncall_schedule],
            errors: result.errors
          }
        end
      end
    end
  end
end
