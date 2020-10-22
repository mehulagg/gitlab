# frozen_string_literal: true

module RequirementsManagement
  class TestReportPolicy < BasePolicy
    delegate { @subject.requirement }
  end
end
