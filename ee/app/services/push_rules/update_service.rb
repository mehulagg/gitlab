# frozen_string_literal: true

module PushRules
  class UpdateService < BaseContainerService
    def execute
      push_rule = container.push_rule || container.build_push_rule

      if push_rule.update(params)
        ServiceResponse.success(payload: push_rule)
      else
        ServiceResponse.error(message: 'Push Rules update failed', payload: push_rule)
      end
    end
  end
end
