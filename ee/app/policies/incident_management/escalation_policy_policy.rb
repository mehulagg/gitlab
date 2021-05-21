# frozen_string_literal: true

module IncidentManagement
  class EscalationPolicyPolicy < ::BasePolicy
    delegate :project
  end
end
