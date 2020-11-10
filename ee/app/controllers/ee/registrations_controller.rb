# frozen_string_literal: true

module EE
  module RegistrationsController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    private

    override :user_created_message
    def user_created_message(confirmed: false)
      experiments = "experiment_growth_recaptcha?#{show_recaptcha_sign_up?}"

      super(confirmed: confirmed) + ", experiments:#{experiments}"
    end
  end
end
