# frozen_string_literal: true

module EE
  module Admin
    module UserEntity
      extend ActiveSupport::Concern

      prepended do
        expose :oncall_schedules, with: ::IncidentManagement::OncallScheduleEntity

        def oncall_schedules
          object.oncall_schedules.uniq
        end
      end
    end
  end
end
