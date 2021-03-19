# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module OncallRotation
      class Preview < Create
        graphql_name 'OncallRotationPreview'

        def resolve(iid:, project_path:, participants:, **args)
          schedule = find_schedule!(iid: iid, project_path: project_path)

          response ::IncidentManagement::OncallRotations::PreviewService.new(
            schedule,
            schedule.project,
            current_user,
            parsed_params(schedule, participants, args)
          ).execute
        end
      end
    end
  end
end
