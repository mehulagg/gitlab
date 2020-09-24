# frozen_string_literal: true

module RequirementsManagement
  class RequirementPolicy < BasePolicy
    delegate { @subject.resource_parent }
  end
end
