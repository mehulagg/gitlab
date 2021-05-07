# frozen_string_literal: true

module IncidentManagement
  class OncallShiftPolicy < ::BasePolicy
    delegate :rotation
  end
end
