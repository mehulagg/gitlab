# frozen_string_literal: true

module IncidentManagement
  class OncallSchedulePolicy < ::BasePolicy
    delegate { @subject.project }
  end
end
