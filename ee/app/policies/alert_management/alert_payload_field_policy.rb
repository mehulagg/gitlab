# frozen_string_literal: true

module AlertManagement
  class AlertPayloadFieldPolicy < ::BasePolicy
    delegate { @subject.project }
  end
end
