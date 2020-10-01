# frozen_string_literal: true

module EE
  module IncidentManagement
    module ProjectIncidentManagementSetting
      extend ActiveSupport::Concern

      prepended do
        validates :sla_timer_minutes,
          presence: true,
          numericality: { greater_than_or_equal_to: 15 },
          if: :sla_timer
      end
    end
  end
end
