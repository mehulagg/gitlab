# frozen_string_literal: true

module EE
  module WelcomeHelper
    include ::Gitlab::Utils::StrongMemoize

    def in_subscription_flow?
      redirect_path == new_subscriptions_path
    end

    def in_trial_flow?
      redirect_path == new_trial_path
    end

    def in_trial_onboarding_flow?
      params[:trial_onboarding_flow] == 'true'
    end

    def in_trial_during_signup_flow?
      params[:trial] == 'true'
    end

    def in_invitation_flow?
      redirect_path.present? && redirect_path.starts_with?('/-/invites/')
    end

    def in_oauth_flow?
      redirect_path&.starts_with?(oauth_authorization_path)
    end

    def setup_for_company_label_text
      if in_subscription_flow?
        _('Who will be using this GitLab subscription?')
      elsif in_trial_flow?
        _('Who will be using this GitLab trial?')
      else
        _('Who will be using GitLab?')
      end
    end

    def show_signup_flow_progress_bar?
      return true if in_subscription_flow?
      return false if in_invitation_flow? || in_oauth_flow? || in_trial_flow?

      onboarding_issues_experiment_enabled?
    end

    def welcome_submit_button_text
      continue = _('Continue')
      get_started = _('Get started!')

      return continue if in_subscription_flow? || in_trial_flow?
      return get_started if in_invitation_flow? || in_oauth_flow?

      onboarding_issues_experiment_enabled? ? continue : get_started
    end

    def data_attributes_for_progress_bar_js_component
      {
        is_in_subscription_flow: in_subscription_flow?.to_s,
        is_onboarding_issues_experiment_enabled: onboarding_issues_experiment_enabled?.to_s
      }
    end

    def skip_setup_for_company?
      current_user.members.any?
    end

    private

    def onboarding_issues_experiment_enabled?
      experiment_enabled?(:onboarding_issues)
    end
  end
end
