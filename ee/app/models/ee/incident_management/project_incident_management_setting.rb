# frozen_string_literal: true

module EE
  module IncidentManagement
    module ProjectIncidentManagementSetting
      extend ActiveSupport::Concern

      ONE_YEAR_IN_MINUTES = 1.year / 1.minute

      prepended do
        validates :sla_timer_minutes,
          presence: true,
          numericality: { greater_than_or_equal_to: 15, less_than_or_equal_to: ONE_YEAR_IN_MINUTES },
          if: :sla_timer
      end
    end
  end
end
