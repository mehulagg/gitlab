# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module OncallRotation
      class Base < BaseMutation
        field :oncall_rotation,
              ::Types::IncidentManagement::OncallRotationType,
              null: true,
              description: 'The on-call rotation.'

        authorize :admin_incident_management_oncall_schedule

        private

        def response(result)
          {
            oncall_rotation: result.payload[:oncall_rotation],
            errors: result.errors
          }
        end

        def find_object(project_path:, schedule_iid:, **args)
          project = Project.find_by_full_path(project_path)

          return unless project

          schedule = ::IncidentManagement::OncallSchedulesFinder.new(current_user, project, iid: schedule_iid).execute.first

          return unless schedule

          args = args.merge(id: args[:id].model_id)

          ::IncidentManagement::OncallRotationsFinder.new(current_user, project, schedule, args).execute.first
        end
      end
    end
  end
end
