# frozen_string_literal: true

module RegistrationsHelper
  def social_signin_enabled?
    ::Gitlab.dev_env_or_com? &&
      omniauth_enabled? &&
      devise_mapping.omniauthable? &&
      button_based_providers_enabled?
  end

  def signup_username_data_attributes
    max_username_length = 255
    min_username_length = 2

    {
      min_length: min_username_length,
      min_length_message: s_('SignUp|Username is too short (minimum is %{min_length} characters).') % { min_length: min_username_length },
      max_length: max_username_length,
      max_length_message: s_('SignUp|Username is too long (maximum is %{max_length} characters).') % { max_length: max_username_length },
      qa_selector: 'new_user_username_field'
    }
  end
end

RegistrationsHelper.prepend_mod_with('RegistrationsHelper')
