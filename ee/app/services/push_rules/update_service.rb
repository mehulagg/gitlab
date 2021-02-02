# frozen_string_literal: true

module PushRules
  class UpdateService < BaseContainerService
    def execute
      push_rule = container.push_rule || container.build_push_rule
      push_rule.assign_attributes(params)

      if push_rule.save
        ServiceResponse.success(payload: push_rule)
      else
        ServiceResponse.error(message: push_rule.errors.messages)
      end
    end
  end
end
