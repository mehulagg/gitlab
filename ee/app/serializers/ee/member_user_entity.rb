# frozen_string_literal: true

module EE
  module MemberUserEntity
    extend ActiveSupport::Concern

    prepended do
      unexpose :gitlab_employee
      unexpose :email
      expose :oncall_schedules, with: ::IncidentManagement::OncallScheduleEntity

      # options[:source] is required to scope the schedules
      # It should be either a Group or Project
      def oncall_schedules
        return [] unless options[:source].present?

        project_ids = options[:source].is_a?(Group) ? options[:source].project_ids : [options[:source].id]

        object.oncall_schedules.select { |schedule| project_ids.include?(schedule.project_id) }
      end
    end
  end
end
