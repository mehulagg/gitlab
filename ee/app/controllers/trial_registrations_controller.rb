# frozen_string_literal: true

class TrialRegistrationsController < RegistrationsController
  before_action :check_if_gl_com_or_dev
  before_action :set_redirect_url, only: :new
  before_action :require_no_authentication_without_flash, only: :new

  def new
    redirect_to new_user_registration_path
  end

  private

  def require_no_authentication_without_flash
    require_no_authentication

    if flash[:alert] == I18n.t('devise.failure.already_authenticated')

      flash[:alert] = nil



    end
  end

  def set_redirect_url
    target_url = new_trial_url(params: request.query_parameters)

    if user_signed_in?
      redirect_to target_url
    else
      store_location_for(:user, target_url)
    end
  end
end
