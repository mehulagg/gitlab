# frozen_string_literal: true

module Registrations
  class WelcomeController < ApplicationController
    layout 'welcome'
    skip_before_action :authenticate_user!, :required_signup_info, :check_two_factor_requirement
    before_action :check_current_user

    def show
      return redirect_to path_for_signed_in_user(current_user) if current_user.role.present? && !current_user.setup_for_company.nil?
    end

    def update
      result = ::Users::SignupService.new(current_user, update_params).execute

      if result[:status] == :success
        if ::Gitlab.com? && show_onboarding_issues_experiment?
          track_experiment_event(:onboarding_issues, 'signed_up')
          record_experiment_user(:onboarding_issues)
        end

        return redirect_to new_users_sign_up_group_path if experiment_enabled?(:onboarding_issues) && show_onboarding_issues_experiment?

        redirect_to path_for_signed_in_user(current_user)
      else
        render :show
      end
    end

    private

    def check_current_user
      return redirect_to new_user_registration_path unless current_user
    end

    def update_params
      params.require(:user).permit(:role, :setup_for_company)
    end

    def requires_confirmation?(user)
      return false if user.confirmed?
      return false if Feature.enabled?(:soft_email_confirmation)
      return false if experiment_enabled?(:signup_flow)

      true
    end

    def path_for_signed_in_user(user)
      if requires_confirmation?(user)
        users_almost_there_path
      else
        stored_location_for(user) || dashboard_projects_path
      end
    end

    def show_onboarding_issues_experiment?
      !helpers.in_subscription_flow? &&
        !helpers.in_invitation_flow? &&
        !helpers.in_oauth_flow? &&
        !helpers.in_trial_flow?
    end
  end
end

Registrations::WelcomeController.prepend_if_ee('EE::Registrations::WelcomeController')
