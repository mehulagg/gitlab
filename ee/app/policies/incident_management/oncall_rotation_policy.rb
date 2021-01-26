# frozen_string_literal: true

module IncidentManagement
  class OncallRotationPolicy < ::BasePolicy
    delegate :project
  end
end
