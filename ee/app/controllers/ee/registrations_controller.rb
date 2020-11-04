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

    def update_registration_params
      clean_params = super.merge(params.require(:user).permit(:email_opted_in))

      clean_params[:email_opted_in] = '1' if clean_params[:setup_for_company] == 'true'

      if clean_params[:email_opted_in] == '1'
        clean_params[:email_opted_in_ip] = request.remote_ip
        clean_params[:email_opted_in_source_id] = User::EMAIL_OPT_IN_SOURCE_ID_GITLAB_COM
        clean_params[:email_opted_in_at] = Time.zone.now
      end

      clean_params
    end
  end
end
