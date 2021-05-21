# frozen_string_literal: true
module ProtectedEnvironments
  class CreateService < ProtectedEnvironments::BaseService
    def execute
      container.protected_environments.create(sanitized_params)
    end
  end
end
