# frozen_string_literal: true
module EE
  module EnvironmentPolicy
    extend ActiveSupport::Concern

    prepended do
      condition(:deployable_by_user) { deployable_by_user? }

      rule { ~deployable_by_user }.policy do
        prevent :stop_environment
        prevent :create_environment_terminal
        prevent :create_deployment
        prevent :update_deployment
        prevent :update_environment
        prevent :destroy_environment
      end

      private

      alias_method :current_user, :user
      alias_method :environment, :subject

      def deployable_by_user?
        environment.protected_deployable_by_user?(current_user)
      end
    end
  end
end
