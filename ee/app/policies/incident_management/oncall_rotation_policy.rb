# frozen_string_literal: true

module IncidentManagement
  class OncallRotationPolicy < ::BasePolicy
    delegate { @subject.project }
  end
end
