# frozen_string_literal: true
module EE
  module EnvironmentPolicy
    extend ActiveSupport::Concern

    prepended do
      condition(:protected_environment) do
        @subject.protected_from?(user)
      end

      rule { protected_environment }.policy do
        prevent :stop_environment
        prevent :create_environment_terminal
        prevent :create_deployment
        prevent :update_deployment
        prevent :update_environment
        prevent :destroy_environment
      end
    end
  end
end
