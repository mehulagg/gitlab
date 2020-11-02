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

    def sign_up_params
      clean_params = super.merge(params.require(:user).permit(:email_opted_in))

      if clean_params[:email_opted_in] == '1'
        clean_params[:email_opted_in_ip] = request.remote_ip
        clean_params[:email_opted_in_source_id] = User::EMAIL_OPT_IN_SOURCE_ID_GITLAB_COM
        clean_params[:email_opted_in_at] = Time.zone.now
      end

      clean_params
    end

    # Part of an experiment to build a new sign up flow. Will be resolved
    # with https://gitlab.com/gitlab-org/growth/engineering/issues/64
    def choose_layout
      if %w(welcome update_registration).include?(action_name)
        'checkout'
      else
        super
      end
    end
  end
end
