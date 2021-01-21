# frozen_string_literal: true

module EE
  module TrialRegistrationHelper
    def social_signin_experiment_enabled?
      ::Gitlab.com? &&
        omniauth_enabled? &&
        devise_mapping.omniauthable? &&
        button_based_providers_enabled? &&
        experiment_enabled?(:trial_registration_with_social_signin)
    end
  end
end
