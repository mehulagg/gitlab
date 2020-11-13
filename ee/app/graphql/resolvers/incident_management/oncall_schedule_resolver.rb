# frozen_string_literal: true

module Resolvers
  module IncidentManagement
    class OncallScheduleResolver < BaseResolver
      alias_method :project, :synchronized_object

      type Types::IncidentManagement::OncallScheduleType.connection_type, null: true

      def resolve(**args)
        return [] unless Ability.allowed?(current_user, :read_incident_management_oncall_schedule, project)

        project.incident_management_oncall_schedules
      end
    end
  end
end
