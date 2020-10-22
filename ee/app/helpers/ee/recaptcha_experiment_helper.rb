# frozen_string_literal: true

module EE
  module RecaptchaExperimentHelper
    include FlipperSessionHelper
    extend ::Gitlab::Utils::Override

    EXPERIMENT_GROWTH_RECAPTCHA_FEATURE_NAME = :experiment_growth_recaptcha

    override :show_recaptcha_sign_up?
    def show_recaptcha_sign_up?
      super && experiment_enabled_for_session?
    end

    private

    def experiment_enabled_for_session?
      ::Feature.enabled?(EXPERIMENT_GROWTH_RECAPTCHA_FEATURE_NAME, flipper_session,
        default_enabled: true)
    end
  end
end
