# frozen_string_literal: true

module EE
  module MemberUserEntity
    extend ActiveSupport::Concern

    prepended do
      unexpose :gitlab_employee
      unexpose :email
      expose :oncall_schedules, with: ::IncidentManagement::OncallScheduleEntity

      def oncall_schedules
        object.oncall_schedules.uniq
      end
    end
  end
end
