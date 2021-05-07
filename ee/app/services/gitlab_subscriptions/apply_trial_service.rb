# frozen_string_literal: true

module GitlabSubscriptions
  class ApplyTrialService
    def execute(apply_trial_params)
      response = client.generate_trial(apply_trial_params)

      if response[:success]
        namespace_id = apply_trial_params.dig(:trial_user, :namespace_id)
        record_onboarding_progress(namespace_id) if namespace_id

        { success: true }
      else
        { success: false, errors: response.dig(:data, :errors) }
      end
    end

    private

    def client
      Gitlab::SubscriptionPortal::Client
    end

    def record_onboarding_progress(namespace_id)
      namespace = Namespace.find_by(id: namespace_id) # rubocop: disable CodeReuse/ActiveRecord
      return unless namespace

      OnboardingProgressService.new(namespace).execute(action: :trial_started)
    end
  end
end
